# QIDI

**Les versions de Moonraker et Klipper sont anciennes et certains fichiers Python ont été modifiés**.

    **git** est un outil puissant qui permet de suivre l'évolution des modifications apportées aux fichiers d'un dépôt.

## Moonraker

En ligne de commande, un simple `git status` permet d'obtenir un aperçu des fichiers ayant été modifiés :

```
mks@mkspi:~$ cd moonraker
mks@mkspi:~/moonraker$ git status
On branch master
Your branch is behind 'origin/master' by 447 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   moonraker/components/file_manager/metadata.py
        modified:   moonraker/components/klippy_apis.py
        modified:   moonraker/components/machine.py

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        moonraker/components/file_manager/update_manager/
        moonraker/components/timelapse.py

no changes added to commit (use "git add" and/or "git commit -a")
mks@mkspi:~/moonraker$
```

En utilisant à la suite de la commande précédente le modificateur `-vv`, les modifications apparaissent encore plus clairement.

`git status -vv`

<details>

```
On branch master
Your branch is behind 'origin/master' by 495 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   moonraker/components/file_manager/metadata.py
	modified:   moonraker/components/klippy_apis.py
	modified:   moonraker/components/machine.py

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	moonraker/components/file_manager/update_manager/
	moonraker/components/timelapse.py

--------------------------------------------------
Changes not staged for commit:
diff --git i/moonraker/components/file_manager/metadata.py w/moonraker/components/file_manager/metadata.py
old mode 100644
new mode 100755
index b425d87..7beefa6
--- i/moonraker/components/file_manager/metadata.py
+++ w/moonraker/components/file_manager/metadata.py
@@ -91,7 +91,7 @@ def _regex_find_int(pattern: str, data: str) -> Optional[int]:
 def _regex_find_string(pattern: str, data: str) -> Optional[str]:
     match = re.search(pattern, data)
     if match:
-        return match.group(1)
+        return match.group(1).strip('"')
     return None
 
 # Slicer parsing implementations
@@ -101,6 +101,7 @@ class BaseSlicer(object):
         self.header_data: str = ""
         self.footer_data: str = ""
         self.layer_height: Optional[float] = None
+        self.has_m486_objects: bool = False
 
     def set_data(self,
                  header_data: str,
@@ -136,9 +137,22 @@ class BaseSlicer(object):
                            data: str,
                            pattern: Optional[str] = None
                            ) -> bool:
-        match = re.search(r"\nDEFINE_OBJECT NAME=", data)
+        match = re.search(
+            r"\n((DEFINE_OBJECT)|(EXCLUDE_OBJECT_DEFINE)) NAME=",
+            data
+        )
         if match is not None:
-            # Objects alread processed
+            # Objects already processed
+            fname = os.path.basename(self.path)
+            log_to_stderr(
+                f"File '{fname}' currently supports cancellation, "
+                "processing aborted"
+            )
+            if match.group(1).startswith("DEFINE_OBJECT"):
+                log_to_stderr(
+                    "Legacy object processing detected.  This is not "
+                    "compatible with official versions of Klipper."
+                )
             return False
         # Always check M486
         patterns = [r"\nM486"]
@@ -146,6 +160,7 @@ class BaseSlicer(object):
             patterns.append(pattern)
         for regex in patterns:
             if re.search(regex, data) is not None:
+                self.has_m486_objects = regex == r"\nM486"
                 return True
         return False
 
@@ -195,6 +210,9 @@ class BaseSlicer(object):
     def parse_first_layer_bed_temp(self) -> Optional[float]:
         return None
 
+    def parse_chamber_temp(self) -> Optional[float]:
+        return None
+
     def parse_first_layer_extr_temp(self) -> Optional[float]:
         return None
 
@@ -292,15 +310,23 @@ class UnknownSlicer(BaseSlicer):
         return _regex_find_first(
             r"M190 S(\d+\.?\d*)", self.header_data)
 
+    def parse_chamber_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r"M191 S(\d+\.?\d*)", self.header_data)
+
     def parse_thumbnails(self) -> Optional[List[Dict[str, Any]]]:
         return None
 
 class PrusaSlicer(BaseSlicer):
     def check_identity(self, data: str) -> Optional[Dict[str, str]]:
         aliases = {
+            'QIDISlicer': r"QIDISlicer\s(.*)\son",
             'PrusaSlicer': r"PrusaSlicer\s(.*)\son",
             'SuperSlicer': r"SuperSlicer\s(.*)\son",
-            'SliCR-3D': r"SliCR-3D\s(.*)\son"
+            'OrcaSlicer': r"OrcaSlicer\s(.*)\son",
+            'SliCR-3D': r"SliCR-3D\s(.*)\son",
+            'BambuStudio': r"BambuStudio[^ ]*\s(.*)\n",
+            'A3dp-Slicer': r"A3dp-Slicer\s(.*)\son",
         }
         for name, expr in aliases.items():
             match = re.search(expr, data)
@@ -387,6 +413,10 @@ class PrusaSlicer(BaseSlicer):
         return _regex_find_first(
             r"; first_layer_bed_temperature = (\d+\.?\d*)", self.footer_data)
 
+    def parse_chamber_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r"; chamber_temperature = (\d+\.?\d*)", self.footer_data)
+
     def parse_nozzle_diameter(self) -> Optional[float]:
         return _regex_find_first(
             r";\snozzle_diameter\s=\s(\d+\.\d*)", self.footer_data)
@@ -395,6 +425,14 @@ class PrusaSlicer(BaseSlicer):
         return _regex_find_int(
             r"; total layers count = (\d+)", self.footer_data)
 
+    def parse_gimage(self) -> Optional[str]:
+        return _regex_find_string(
+            r";gimage:(.*)", self.footer_data)
+
+    def parse_simage(self) -> Optional[str]:
+        return _regex_find_string(
+            r";simage:(.*)", self.footer_data)
+
 class Slic3rPE(PrusaSlicer):
     def check_identity(self, data: str) -> Optional[Dict[str, str]]:
         match = re.search(r"Slic3r\sPrusa\sEdition\s(.*)\son", data)
@@ -491,6 +529,10 @@ class Cura(BaseSlicer):
         return _regex_find_first(
             r"M190 S(\d+\.?\d*)", self.header_data)
 
+    def parse_chamber_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r"M191 S(\d+\.?\d*)", self.header_data)
+
     def parse_layer_count(self) -> Optional[int]:
         return _regex_find_int(
             r";LAYER_COUNT\:(\d+)", self.header_data)
@@ -535,10 +577,20 @@ class Cura(BaseSlicer):
             return None
         return thumbs
 
+    def parse_gimage(self) -> Optional[str]:
+        return _regex_find_string(
+            r";gimage:(.*)", self.header_data)
+
+    def parse_simage(self) -> Optional[str]:
+        return _regex_find_string(
+            r";simage:(.*)", self.header_data)
+
 class Simplify3D(BaseSlicer):
     def check_identity(self, data: str) -> Optional[Dict[str, str]]:
         match = re.search(r"Simplify3D\(R\)\sVersion\s(.*)", data)
         if match:
+            self._version = match.group(1)
+            self._is_v5 = self._version.startswith("5")
             return {
                 'slicer': "Simplify3D",
                 'slicer_version': match.group(1)
@@ -558,19 +610,27 @@ class Simplify3D(BaseSlicer):
 
     def parse_filament_total(self) -> Optional[float]:
         return _regex_find_first(
-            r";\s+Filament\slength:\s(\d+\.?\d*)\smm", self.footer_data)
+            r";\s+(?:Filament\slength|Material\sLength):\s(\d+\.?\d*)\smm",
+            self.footer_data
+        )
 
     def parse_filament_weight_total(self) -> Optional[float]:
         return _regex_find_first(
-            r";\s+Plastic\sweight:\s(\d+\.?\d*)\sg", self.footer_data)
+            r";\s+(?:Plastic\sweight|Material\sWeight):\s(\d+\.?\d*)\sg",
+            self.footer_data
+        )
 
     def parse_filament_name(self) -> Optional[str]:
         return _regex_find_string(
             r";\s+printMaterial,(.*)", self.header_data)
 
+    def parse_filament_type(self) -> Optional[str]:
+        return _regex_find_string(
+            r";\s+makerBotModelMaterial,(.*)", self.footer_data)
+
     def parse_estimated_time(self) -> Optional[float]:
         time_match = re.search(
-            r';\s+Build time:.*', self.footer_data)
+            r';\s+Build (t|T)ime:.*', self.footer_data)
         if not time_match:
             return None
         total_time = 0
@@ -603,15 +663,37 @@ class Simplify3D(BaseSlicer):
                     return None
         return None
 
+    def _get_first_layer_temp_v5(self, heater_type: str) -> Optional[float]:
+        pattern = (
+            r";\s+temperatureController,.+?"
+            r";\s+temperatureType,"f"{heater_type}"r".+?"
+            r";\s+temperatureSetpoints,\d+\|(\d+)"
+        )
+        match = re.search(pattern, self.header_data, re.MULTILINE | re.DOTALL)
+        if match is not None:
+            try:
+                return float(match.group(1))
+            except Exception:
+                return None
+        return None
+
     def parse_first_layer_extr_temp(self) -> Optional[float]:
-        return self._get_first_layer_temp("Extruder 1")
+        if self._is_v5:
+            return self._get_first_layer_temp_v5("extruder")
+        else:
+            return self._get_first_layer_temp("Extruder 1")
 
     def parse_first_layer_bed_temp(self) -> Optional[float]:
-        return self._get_first_layer_temp("Heated Bed")
+        if self._is_v5:
+            return self._get_first_layer_temp_v5("platform")
+        else:
+            return self._get_first_layer_temp("Heated Bed")
 
     def parse_nozzle_diameter(self) -> Optional[float]:
         return _regex_find_first(
-            r";\s+extruderDiameter,(\d+\.\d*)", self.header_data)
+            r";\s+(?:extruderDiameter|nozzleDiameter),(\d+\.\d*)",
+            self.header_data
+        )
 
 class KISSlicer(BaseSlicer):
     def check_identity(self, data: str) -> Optional[Dict[str, Any]]:
@@ -662,6 +744,10 @@ class KISSlicer(BaseSlicer):
         return _regex_find_first(
             r"; bed_C = (\d+\.?\d*)", self.header_data)
 
+    def parse_chamber_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r"; chamber_C = (\d+\.?\d*)", self.header_data)
+
 
 class IdeaMaker(BaseSlicer):
     def check_identity(self, data: str) -> Optional[Dict[str, str]]:
@@ -741,6 +827,10 @@ class IdeaMaker(BaseSlicer):
         return _regex_find_first(
             r"M190 S(\d+\.?\d*)", self.header_data)
 
+    def parse_chamber_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r"M191 S(\d+\.?\d*)", self.header_data)
+
     def parse_nozzle_diameter(self) -> Optional[float]:
         return _regex_find_first(
             r";Dimension:(?:\s\d+\.\d+){3}\s(\d+\.\d+)", self.header_data)
@@ -779,6 +869,10 @@ class IceSL(BaseSlicer):
         return _regex_find_first(
             r";\sbed_temp_degree_c\s:\s+(\d+\.?\d*)", self.header_data)
 
+    def parse_chamber_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r";\schamber_temp_degree_c\s:\s+(\d+\.?\d*)", self.header_data)
+
     def parse_filament_total(self) -> Optional[float]:
         return _regex_find_first(
             r";\sfilament_used_mm\s:\s+(\d+\.\d+)", self.header_data)
@@ -807,13 +901,76 @@ class IceSL(BaseSlicer):
         return _regex_find_first(
             r";\snozzle_diameter_mm_0\s:\s+(\d+\.\d+)", self.header_data)
 
+class KiriMoto(BaseSlicer):
+    def check_identity(self, data) -> Optional[Dict[str, Any]]:
+        variants: Dict[str, str] = {
+            "Kiri:Moto": r"; Generated by Kiri:Moto (\d.+)",
+            "SimplyPrint": r"; Generated by Kiri:Moto \(SimplyPrint\) (.+)"
+        }
+        for name, pattern in variants.items():
+            match = re.search(pattern, data)
+            if match:
+                return {
+                    "slicer": name,
+                    "slicer_version": match.group(1)
+                }
+        return None
+
+    def parse_first_layer_height(self) -> Optional[float]:
+        return _regex_find_first(
+            r"; firstSliceHeight = (\d+\.\d+)", self.header_data
+        )
+
+    def parse_layer_height(self) -> Optional[float]:
+        self.layer_height = _regex_find_first(
+            r"; sliceHeight = (\d+\.\d+)", self.header_data
+        )
+        return self.layer_height
+
+    def parse_object_height(self) -> Optional[float]:
+        return self._parse_max_float(
+            r"G1 Z\d+\.\d+ (?:; z-hop end|F\d+\n)",
+            self.footer_data, strict=True
+        )
+
+    def parse_layer_count(self) -> Optional[int]:
+        matches = re.findall(
+            r";; --- layer (\d+) \(.+", self.footer_data
+        )
+        if not matches:
+            return None
+        try:
+            return int(matches[-1]) + 1
+        except Exception:
+            return None
+
+    def parse_estimated_time(self) -> Optional[float]:
+        return _regex_find_int(r"; --- print time: (\d+)s", self.footer_data)
+
+    def parse_filament_total(self) -> Optional[float]:
+        return _regex_find_first(
+            r"; --- filament used: (\d+\.?\d*) mm", self.footer_data
+        )
+
+    def parse_first_layer_extr_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r"; firstLayerNozzleTemp = (\d+\.?\d*)", self.header_data
+        )
+
+    def parse_first_layer_bed_temp(self) -> Optional[float]:
+        return _regex_find_first(
+            r"; firstLayerBedTemp = (\d+\.?\d*)", self.header_data
+        )
+
 
 READ_SIZE = 512 * 1024
 SUPPORTED_SLICERS: List[Type[BaseSlicer]] = [
     PrusaSlicer, Slic3rPE, Slic3r, Cura, Simplify3D,
-    KISSlicer, IdeaMaker, IceSL
+    KISSlicer, IdeaMaker, IceSL, KiriMoto
 ]
 SUPPORTED_DATA = [
+    'gimage',
+    'simage',
     'gcode_start_byte',
     'gcode_end_byte',
     'layer_count',
@@ -824,25 +981,55 @@ SUPPORTED_DATA = [
     'first_layer_height',
     'first_layer_extr_temp',
     'first_layer_bed_temp',
+    'chamber_temp',
     'filament_name',
     'filament_type',
     'filament_total',
     'filament_weight_total',
     'thumbnails']
 
-def process_objects(file_path: str) -> bool:
+def process_objects(file_path: str, slicer: BaseSlicer, name: str) -> bool:
     try:
-        from preprocess_cancellation import preprocessor
+        from preprocess_cancellation import (
+            preprocess_slicer,
+            preprocess_cura,
+            preprocess_ideamaker,
+            preprocess_m486
+        )
     except ImportError:
         log_to_stderr("Module 'preprocess-cancellation' failed to load")
         return False
     fname = os.path.basename(file_path)
-    log_to_stderr(f"Performing Object Processing on file: {fname}")
+    log_to_stderr(
+        f"Performing Object Processing on file: {fname}, "
+        f"sliced by {name}"
+    )
     with tempfile.TemporaryDirectory() as tmp_dir_name:
         tmp_file = os.path.join(tmp_dir_name, fname)
         with open(file_path, 'r') as in_file:
             with open(tmp_file, 'w') as out_file:
-                preprocessor(in_file, out_file)
+                try:
+                    if slicer.has_m486_objects:
+                        processor = preprocess_m486
+                    elif isinstance(slicer, PrusaSlicer):
+                        processor = preprocess_slicer
+                    elif isinstance(slicer, Cura):
+                        processor = preprocess_cura
+                    elif isinstance(slicer, IdeaMaker):
+                        processor = preprocess_ideamaker
+                    else:
+                        log_to_stderr(
+                            f"Object Processing Failed, slicer {name}"
+                            "not supported"
+                        )
+                        return False
+                    for line in processor(in_file):
+                        out_file.write(line)
+                except Exception as e:
+                    log_to_stderr(f"Object processing failed: {e}")
+                    return False
+        if os.path.islink(file_path):
+            file_path = os.path.realpath(file_path)
         shutil.move(tmp_file, file_path)
     return True
 
@@ -881,7 +1068,8 @@ def extract_metadata(
     metadata: Dict[str, Any] = {}
     slicer, ident = get_slicer(file_path)
     if check_objects and slicer.has_objects():
-        if process_objects(file_path):
+        name = ident.get("slicer", "unknown")
+        if process_objects(file_path, slicer, name):
             slicer, ident = get_slicer(file_path)
     metadata['size'] = os.path.getsize(file_path)
     metadata['modified'] = os.path.getmtime(file_path)
@@ -911,6 +1099,8 @@ def extract_ufp(ufp_path: str, dest_path: str) -> None:
                 if UFP_THUMB_PATH in zf.namelist():
                     tmp_thumb_path = zf.extract(
                         UFP_THUMB_PATH, path=tmp_dir_name)
+            if os.path.islink(dest_path):
+                dest_path = os.path.realpath(dest_path)
             shutil.move(tmp_model_path, dest_path)
             if tmp_thumb_path:
                 if not os.path.exists(dest_thumb_dir):
@@ -975,4 +1165,4 @@ if __name__ == "__main__":
     check_objects = args.check_objects
     enabled_msg = "enabled" if check_objects else "disabled"
     log_to_stderr(f"Object Processing is {enabled_msg}")
-    main(args.path, args.filename, args.ufp, check_objects)
+    main(args.path, args.filename, args.ufp, check_objects)
\ No newline at end of file
diff --git i/moonraker/components/klippy_apis.py w/moonraker/components/klippy_apis.py
index 59314ba..509f011 100644
--- i/moonraker/components/klippy_apis.py
+++ w/moonraker/components/klippy_apis.py
@@ -7,6 +7,11 @@
 from __future__ import annotations
 from utils import SentinelClass
 from websockets import WebRequest, Subscribable
+import os
+import shutil
+import time
+import logging
+import json
 
 # Annotation imports
 from typing import (
@@ -23,6 +28,7 @@ if TYPE_CHECKING:
     from confighelper import ConfigHelper
     from websockets import WebRequest
     from klippy_connection import KlippyConnection as Klippy
+    from .file_manager.file_manager import FileManager
     Subscription = Dict[str, Optional[List[Any]]]
     _T = TypeVar("_T")
 
@@ -41,6 +47,7 @@ class KlippyAPI(Subscribable):
     def __init__(self, config: ConfigHelper) -> None:
         self.server = config.get_server()
         self.klippy: Klippy = self.server.lookup_component("klippy_connection")
+        self.fm: FileManager = self.server.lookup_component("file_manager")
         app_args = self.server.get_app_args()
         self.version = app_args.get('software_version')
         # Maintain a subscription for all moonraker requests, as
@@ -110,10 +117,24 @@ class KlippyAPI(Subscribable):
         # Doing so will result in "wait_started" blocking for the specifed
         # timeout (default 20s) and returning False.
         # XXX - validate that file is on disk
+        homedir = os.path.expanduser("~")
         if filename[0] == '/':
             filename = filename[1:]
         # Escape existing double quotes in the file name
         filename = filename.replace("\"", "\\\"")
+        if os.path.split(filename)[0].split(os.path.sep)[0] != ".cache":
+            base_path = os.path.join(homedir, "gcode_files")
+            target = os.path.join(".cache", os.path.basename(filename))
+            cache_path = os.path.join(base_path, ".cache")
+            if not os.path.exists(cache_path):
+                os.makedirs(cache_path)
+            shutil.rmtree(cache_path)
+            os.makedirs(cache_path)
+            metadata = self.fm.gcode_metadata.metadata.get(filename, None)
+            self.copy_file_to_cache(os.path.join(base_path, filename), os.path.join(base_path, target))
+            msg = "// metadata=" + json.dumps(metadata)
+            self.server.send_event("server:gcode_response", msg)
+            filename = target
         script = f'SDCARD_PRINT_FILE FILENAME="{filename}"'
         await self.klippy.wait_started()
         return await self.run_gcode(script)
@@ -232,5 +253,16 @@ class KlippyAPI(Subscribable):
                     ) -> None:
         self.server.send_event("server:status_update", status)
 
+    def copy_file_to_cache(self, origin, target):
+        stat = os.statvfs("/")
+        free_space = stat.f_frsize * stat.f_bfree
+        filesize = os.path.getsize(os.path.join(origin))
+        if (filesize < free_space):
+            shutil.copy(origin, target)
+        else:
+            msg = "!! Insufficient disk space, unable to read the file."
+            self.server.send_event("server:gcode_response", msg)
+            raise self.server.error("Insufficient disk space, unable to read the file.", 500)
+
 def load_component(config: ConfigHelper) -> KlippyAPI:
     return KlippyAPI(config)
diff --git i/moonraker/components/machine.py w/moonraker/components/machine.py
index 87231a2..977e3d6 100644
--- i/moonraker/components/machine.py
+++ w/moonraker/components/machine.py
@@ -102,6 +102,13 @@ class Machine:
         self.server.register_endpoint(
             "/machine/system_info", ['GET'],
             self._handle_sysinfo_request)
+        self.server.register_endpoint(
+            "/machine/system_info", ['POST'],
+            self._handle_sysinfo_request)
+        # self.server.register_endpoint(
+            # "/machine/dev_name", ['GET'],
+            # self._handle_devname_request)
+
 
         self.server.register_notification("machine:service_state_changed")
 
@@ -194,8 +201,21 @@ class Machine:
     async def _handle_sysinfo_request(self,
                                       web_request: WebRequest
                                       ) -> Dict[str, Any]:
+        # with open('../../../../../root/www/dev_info.txt', 'r') as f:
+        dev_name = web_request.get_str('dev_name',default=None)
+        if dev_name !=None:
+            Note=open('dev_info.txt',mode='w')   
+            Note.write(dev_name)   
+            Note.close()
+        # path=os.path.abspath('.')
+        with open('dev_info.txt', 'r') as f:         
+            content = f.read() 
+            f.close()
+        self.system_info["machine_name"] =  content            
         return {'system_info': self.system_info}
 
+
+
     def get_system_info(self) -> Dict[str, Any]:
         return self.system_info
 
no changes added to commit (use "git add" and/or "git commit -a")

```
  
</details>

## Klipper

```
mks@mkspi:~/moonraker$ cd ../klipper
mks@mkspi:~/klipper$ git status
On branch master
Your branch is behind 'origin/master' by 379 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   klippy/extras/angle.py
        modified:   klippy/extras/endstop_phase.py
        modified:   klippy/extras/force_move.py
        modified:   klippy/extras/probe.py
        modified:   klippy/extras/spi_temperature.py
        modified:   klippy/extras/tmc.py
        modified:   klippy/extras/virtual_sdcard.py
        modified:   klippy/gcode.py
        modified:   klippy/klippy.py
        modified:   klippy/mcu.py

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        klippy/extras/tmc2240.py
        klippy/extras/x_twist_compensation.py

no changes added to commit (use "git add" and/or "git commit -a")
```

`git status -vv`

<details>

```
On branch master
Your branch is behind 'origin/master' by 416 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   klippy/extras/angle.py
	modified:   klippy/extras/endstop_phase.py
	modified:   klippy/extras/force_move.py
	modified:   klippy/extras/probe.py
	modified:   klippy/extras/spi_temperature.py
	modified:   klippy/extras/tmc.py
	modified:   klippy/extras/virtual_sdcard.py
	modified:   klippy/gcode.py
	modified:   klippy/klippy.py
	modified:   klippy/mcu.py

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	klippy/extras/gcode_shell_command.py
	klippy/extras/tmc2240.py
	klippy/extras/x_twist_compensation.py

--------------------------------------------------
Changes not staged for commit:
diff --git i/klippy/extras/angle.py w/klippy/extras/angle.py
index d61a7634..1d154579 100644
--- i/klippy/extras/angle.py
+++ w/klippy/extras/angle.py
@@ -1,578 +1,578 @@
-# Support for reading SPI magnetic angle sensors
-#
-# Copyright (C) 2021,2022  Kevin O'Connor <kevin@koconnor.net>
-#
-# This file may be distributed under the terms of the GNU GPLv3 license.
-import logging, math, threading
-from . import bus, motion_report
-
-MIN_MSG_TIME = 0.100
-TCODE_ERROR = 0xff
-
-TRINAMIC_DRIVERS = ["tmc2130", "tmc2208", "tmc2209", "tmc2660", "tmc5160"]
-
-CALIBRATION_BITS = 6 # 64 entries
-ANGLE_BITS = 16 # angles range from 0..65535
-
-class AngleCalibration:
-    def __init__(self, config):
-        self.printer = config.get_printer()
-        self.name = config.get_name()
-        self.stepper_name = config.get('stepper', None)
-        if self.stepper_name is None:
-            # No calibration
-            return
-        try:
-            import numpy
-        except:
-            raise config.error("Angle calibration requires numpy module")
-        sconfig = config.getsection(self.stepper_name)
-        sconfig.getint('microsteps', note_valid=False)
-        self.tmc_module = self.mcu_stepper = None
-        # Current calibration data
-        self.mcu_pos_offset = None
-        self.angle_phase_offset = 0.
-        self.calibration_reversed = False
-        self.calibration = []
-        cal = config.get('calibrate', None)
-        if cal is not None:
-            data = [d.strip() for d in cal.split(',')]
-            angles = [float(d) for d in data if d]
-            self.load_calibration(angles)
-        # Register commands
-        self.printer.register_event_handler("stepper:sync_mcu_position",
-                                            self.handle_sync_mcu_pos)
-        self.printer.register_event_handler("klippy:connect", self.connect)
-        cname = self.name.split()[-1]
-        gcode = self.printer.lookup_object('gcode')
-        gcode.register_mux_command("ANGLE_CALIBRATE", "CHIP",
-                                   cname, self.cmd_ANGLE_CALIBRATE,
-                                   desc=self.cmd_ANGLE_CALIBRATE_help)
-    def handle_sync_mcu_pos(self, mcu_stepper):
-        if mcu_stepper.get_name() == self.stepper_name:
-            self.mcu_pos_offset = None
-    def calc_mcu_pos_offset(self, sample):
-        # Lookup phase information
-        mcu_phase_offset, phases = self.tmc_module.get_phase_offset()
-        if mcu_phase_offset is None:
-            return
-        # Find mcu position at time of sample
-        angle_time, angle_pos = sample
-        mcu_pos = self.mcu_stepper.get_past_mcu_position(angle_time)
-        # Convert angle_pos to mcu_pos units
-        microsteps, full_steps = self.get_microsteps()
-        angle_to_mcu_pos = full_steps * microsteps / float(1<<ANGLE_BITS)
-        angle_mpos = angle_pos * angle_to_mcu_pos
-        # Calculate adjustment for stepper phases
-        phase_diff = ((angle_mpos + self.angle_phase_offset * angle_to_mcu_pos)
-                      - (mcu_pos + mcu_phase_offset)) % phases
-        if phase_diff > phases//2:
-            phase_diff -= phases
-        # Store final offset
-        self.mcu_pos_offset = mcu_pos - (angle_mpos - phase_diff)
-    def apply_calibration(self, samples):
-        calibration = self.calibration
-        if not calibration:
-            return None
-        calibration_reversed = self.calibration_reversed
-        interp_bits = ANGLE_BITS - CALIBRATION_BITS
-        interp_mask = (1 << interp_bits) - 1
-        interp_round = 1 << (interp_bits - 1)
-        for i, (samp_time, angle) in enumerate(samples):
-            bucket = (angle & 0xffff) >> interp_bits
-            cal1 = calibration[bucket]
-            cal2 = calibration[bucket + 1]
-            adj = (angle & interp_mask) * (cal2 - cal1)
-            adj = cal1 + ((adj + interp_round) >> interp_bits)
-            angle_diff = (angle - adj) & 0xffff
-            angle_diff -= (angle_diff & 0x8000) << 1
-            new_angle = angle - angle_diff
-            if calibration_reversed:
-                new_angle = -new_angle
-            samples[i] = (samp_time, new_angle)
-        if self.mcu_pos_offset is None:
-            self.calc_mcu_pos_offset(samples[0])
-            if self.mcu_pos_offset is None:
-                return None
-        return self.mcu_stepper.mcu_to_commanded_position(self.mcu_pos_offset)
-    def load_calibration(self, angles):
-        # Calculate linear intepolation calibration buckets by solving
-        # linear equations
-        angle_max = 1 << ANGLE_BITS
-        calibration_count = 1 << CALIBRATION_BITS
-        bucket_size = angle_max // calibration_count
-        full_steps = len(angles)
-        nominal_step = float(angle_max) / full_steps
-        self.angle_phase_offset = (angles.index(min(angles)) & 3) * nominal_step
-        self.calibration_reversed = angles[-2] > angles[-1]
-        if self.calibration_reversed:
-            angles = list(reversed(angles))
-        first_step = angles.index(min(angles))
-        angles = angles[first_step:] + angles[:first_step]
-        import numpy
-        eqs = numpy.zeros((full_steps, calibration_count))
-        ans = numpy.zeros((full_steps,))
-        for step, angle in enumerate(angles):
-            int_angle = int(angle + .5) % angle_max
-            bucket = int(int_angle / bucket_size)
-            bucket_start = bucket * bucket_size
-            ang_diff = angle - bucket_start
-            ang_diff_per = ang_diff / bucket_size
-            eq = eqs[step]
-            eq[bucket] = 1. - ang_diff_per
-            eq[(bucket + 1) % calibration_count] = ang_diff_per
-            ans[step] = float(step * nominal_step)
-            if bucket + 1 >= calibration_count:
-                ans[step] -= ang_diff_per * angle_max
-        sol = numpy.linalg.lstsq(eqs, ans, rcond=None)[0]
-        isol = [int(s + .5) for s in sol]
-        self.calibration = isol + [isol[0] + angle_max]
-    def lookup_tmc(self):
-        for driver in TRINAMIC_DRIVERS:
-            driver_name = "%s %s" % (driver, self.stepper_name)
-            module = self.printer.lookup_object(driver_name, None)
-            if module is not None:
-                return module
-        raise self.printer.command_error("Unable to find TMC driver for %s"
-                                         % (self.stepper_name,))
-    def connect(self):
-        self.tmc_module = self.lookup_tmc()
-        fmove = self.printer.lookup_object('force_move')
-        self.mcu_stepper = fmove.lookup_stepper(self.stepper_name)
-    def get_microsteps(self):
-        configfile = self.printer.lookup_object('configfile')
-        sconfig = configfile.get_status(None)['settings']
-        stconfig = sconfig.get(self.stepper_name, {})
-        microsteps = stconfig['microsteps']
-        full_steps = stconfig['full_steps_per_rotation']
-        return microsteps, full_steps
-    def get_stepper_phase(self):
-        mcu_phase_offset, phases = self.tmc_module.get_phase_offset()
-        if mcu_phase_offset is None:
-            raise self.printer.command_error("Driver phase not known for %s"
-                                             % (self.stepper_name,))
-        mcu_pos = self.mcu_stepper.get_mcu_position()
-        return (mcu_pos + mcu_phase_offset) % phases
-    def do_calibration_moves(self):
-        move = self.printer.lookup_object('force_move').manual_move
-        # Start data collection
-        angle_sensor = self.printer.lookup_object(self.name)
-        cconn = angle_sensor.start_internal_client()
-        # Move stepper several turns (to allow internal sensor calibration)
-        microsteps, full_steps = self.get_microsteps()
-        mcu_stepper = self.mcu_stepper
-        step_dist = mcu_stepper.get_step_dist()
-        full_step_dist = step_dist * microsteps
-        rotation_dist = full_steps * full_step_dist
-        align_dist = step_dist * self.get_stepper_phase()
-        move_time = 0.010
-        move_speed = full_step_dist / move_time
-        move(mcu_stepper, -(rotation_dist+align_dist), move_speed)
-        move(mcu_stepper, 2. * rotation_dist, move_speed)
-        move(mcu_stepper, -2. * rotation_dist, move_speed)
-        move(mcu_stepper, .5 * rotation_dist - full_step_dist, move_speed)
-        # Move to each full step position
-        toolhead = self.printer.lookup_object('toolhead')
-        times = []
-        samp_dist = full_step_dist
-        for i in range(2 * full_steps):
-            move(mcu_stepper, samp_dist, move_speed)
-            start_query_time = toolhead.get_last_move_time() + 0.050
-            end_query_time = start_query_time + 0.050
-            times.append((start_query_time, end_query_time))
-            toolhead.dwell(0.150)
-            if i == full_steps-1:
-                # Reverse direction and test each full step again
-                move(mcu_stepper, .5 * rotation_dist, move_speed)
-                move(mcu_stepper, -.5 * rotation_dist + samp_dist, move_speed)
-                samp_dist = -samp_dist
-        move(mcu_stepper, .5*rotation_dist + align_dist, move_speed)
-        toolhead.wait_moves()
-        # Finish data collection
-        cconn.finalize()
-        msgs = cconn.get_messages()
-        # Correlate query responses
-        cal = {}
-        step = 0
-        for msg in msgs:
-            for query_time, pos in msg['params']['data']:
-                # Add to step tracking
-                while step < len(times) and query_time > times[step][1]:
-                    step += 1
-                if step < len(times) and query_time >= times[step][0]:
-                    cal.setdefault(step, []).append(pos)
-        if len(cal) != len(times):
-            raise self.printer.command_error(
-                "Failed calibration - incomplete sensor data")
-        fcal = { i: cal[i] for i in range(full_steps) }
-        rcal = { full_steps-i-1: cal[i+full_steps] for i in range(full_steps) }
-        return fcal, rcal
-    def calc_angles(self, meas):
-        total_count = total_variance = 0
-        angles = {}
-        for step, data in meas.items():
-            count = len(data)
-            angle_avg = float(sum(data)) / count
-            angles[step] = angle_avg
-            total_count += count
-            total_variance += sum([(d - angle_avg)**2 for d in data])
-        return angles, math.sqrt(total_variance / total_count), total_count
-    cmd_ANGLE_CALIBRATE_help = "Calibrate angle sensor to stepper motor"
-    def cmd_ANGLE_CALIBRATE(self, gcmd):
-        # Perform calibration movement and capture
-        old_calibration = self.calibration
-        self.calibration = []
-        try:
-            fcal, rcal = self.do_calibration_moves()
-        finally:
-            self.calibration = old_calibration
-        # Calculate each step position average and variance
-        microsteps, full_steps = self.get_microsteps()
-        fangles, fstd, ftotal = self.calc_angles(fcal)
-        rangles, rstd, rtotal = self.calc_angles(rcal)
-        if (len({a: i for i, a in fangles.items()}) != len(fangles)
-            or len({a: i for i, a in rangles.items()}) != len(rangles)):
-            raise self.printer.command_error(
-                "Failed calibration - sensor not updating for each step")
-        merged = { i: fcal[i] + rcal[i] for i in range(full_steps) }
-        angles, std, total = self.calc_angles(merged)
-        gcmd.respond_info("angle: stddev=%.3f (%.3f forward / %.3f reverse)"
-                          " in %d queries" % (std, fstd, rstd, total))
-        # Order data with lowest/highest magnet position first
-        anglist = [angles[i] % 0xffff for i in range(full_steps)]
-        if angles[0] > angles[1]:
-            first_ang = max(anglist)
-        else:
-            first_ang = min(anglist)
-        first_phase = anglist.index(first_ang) & ~3
-        anglist = anglist[first_phase:] + anglist[:first_phase]
-        # Save results
-        cal_contents = []
-        for i, angle in enumerate(anglist):
-            if not i % 8:
-                cal_contents.append('\n')
-            cal_contents.append("%.1f" % (angle,))
-            cal_contents.append(',')
-        cal_contents.pop()
-        configfile = self.printer.lookup_object('configfile')
-        configfile.remove_section(self.name)
-        configfile.set(self.name, 'calibrate', ''.join(cal_contents))
-
-class HelperA1333:
-    SPI_MODE = 3
-    SPI_SPEED = 10000000
-    def __init__(self, config, spi, oid):
-        self.spi = spi
-        self.is_tcode_absolute = False
-        self.last_temperature = None
-    def get_static_delay(self):
-        return .000001
-    def start(self):
-        # Setup for angle query
-        self.spi.spi_transfer([0x32, 0x00])
-
-class HelperAS5047D:
-    SPI_MODE = 1
-    SPI_SPEED = int(1. / .000000350)
-    def __init__(self, config, spi, oid):
-        self.spi = spi
-        self.is_tcode_absolute = False
-        self.last_temperature = None
-    def get_static_delay(self):
-        return .000100
-    def start(self):
-        # Clear any errors from device
-        self.spi.spi_transfer([0xff, 0xfc]) # Read DIAAGC
-        self.spi.spi_transfer([0x40, 0x01]) # Read ERRFL
-        self.spi.spi_transfer([0xc0, 0x00]) # Read NOP
-
-class HelperTLE5012B:
-    SPI_MODE = 1
-    SPI_SPEED = 4000000
-    def __init__(self, config, spi, oid):
-        self.printer = config.get_printer()
-        self.spi = spi
-        self.oid = oid
-        self.is_tcode_absolute = True
-        self.last_temperature = None
-        self.mcu = spi.get_mcu()
-        self.mcu.register_config_callback(self._build_config)
-        self.spi_angle_transfer_cmd = None
-        self.last_chip_mcu_clock = self.last_chip_clock = 0
-        self.chip_freq = 0.
-        name = config.get_name().split()[-1]
-        gcode = self.printer.lookup_object("gcode")
-        gcode.register_mux_command("ANGLE_DEBUG_READ", "CHIP", name,
-                                   self.cmd_ANGLE_DEBUG_READ,
-                                   desc=self.cmd_ANGLE_DEBUG_READ_help)
-        gcode.register_mux_command("ANGLE_DEBUG_WRITE", "CHIP", name,
-                                   self.cmd_ANGLE_DEBUG_WRITE,
-                                   desc=self.cmd_ANGLE_DEBUG_WRITE_help)
-    def _build_config(self):
-        cmdqueue = self.spi.get_command_queue()
-        self.spi_angle_transfer_cmd = self.mcu.lookup_query_command(
-            "spi_angle_transfer oid=%c data=%*s",
-            "spi_angle_transfer_response oid=%c clock=%u response=%*s",
-            oid=self.oid, cq=cmdqueue)
-    def get_tcode_params(self):
-        return self.last_chip_mcu_clock, self.last_chip_clock, self.chip_freq
-    def _calc_crc(self, data):
-        crc = 0xff
-        for d in data:
-            crc ^= d
-            for i in range(8):
-                if crc & 0x80:
-                    crc = (crc << 1) ^ 0x1d
-                else:
-                    crc <<= 1
-        return (~crc) & 0xff
-    def _send_spi(self, msg):
-        for retry in range(5):
-            if msg[0] & 0x04:
-                params = self.spi_angle_transfer_cmd.send([self.oid, msg])
-            else:
-                params = self.spi.spi_transfer(msg)
-            resp = bytearray(params['response'])
-            crc = self._calc_crc(bytearray(msg[:2]) + resp[2:-2])
-            if crc == resp[-1]:
-                return params
-        raise self.printer.command_error("Unable to query tle5012b chip")
-    def _read_reg(self, reg):
-        cw = 0x8000 | ((reg & 0x3f) << 4) | 0x01
-        if reg >= 0x05 and reg <= 0x11:
-            cw |= 0x5000
-        msg = [cw >> 8, cw & 0xff, 0, 0, 0, 0]
-        params = self._send_spi(msg)
-        resp = bytearray(params['response'])
-        return (resp[2] << 8) | resp[3]
-    def _write_reg(self, reg, val):
-        cw = ((reg & 0x3f) << 4) | 0x01
-        if reg >= 0x05 and reg <= 0x11:
-            cw |= 0x5000
-        msg = [cw >> 8, cw & 0xff, (val >> 8) & 0xff, val & 0xff, 0, 0]
-        for retry in range(5):
-            self._send_spi(msg)
-            rval = self._read_reg(reg)
-            if rval == val:
-                return
-        raise self.printer.command_error("Unable to write to tle5012b chip")
-    def _mask_reg(self, reg, off, on):
-        rval = self._read_reg(reg)
-        self._write_reg(reg, (rval & ~off) | on)
-    def _query_clock(self):
-        # Read frame counter (and normalize to a 16bit counter)
-        msg = [0x84, 0x42, 0, 0, 0, 0, 0, 0] # Read with latch, AREV and FSYNC
-        params = self._send_spi(msg)
-        resp = bytearray(params['response'])
-        mcu_clock = self.mcu.clock32_to_clock64(params['clock'])
-        chip_clock = ((resp[2] & 0x7e) << 9) | ((resp[4] & 0x3e) << 4)
-        # Calculate temperature
-        temper = resp[5] - ((resp[4] & 0x01) << 8)
-        self.last_temperature = (temper + 152) / 2.776
-        return mcu_clock, chip_clock
-    def update_clock(self):
-        mcu_clock, chip_clock = self._query_clock()
-        mdiff = mcu_clock - self.last_chip_mcu_clock
-        chip_mclock = self.last_chip_clock + int(mdiff * self.chip_freq + .5)
-        cdiff = (chip_mclock - chip_clock) & 0xffff
-        cdiff -= (cdiff & 0x8000) << 1
-        new_chip_clock = chip_mclock - cdiff
-        self.chip_freq = float(new_chip_clock - self.last_chip_clock) / mdiff
-        self.last_chip_clock = new_chip_clock
-        self.last_chip_mcu_clock = mcu_clock
-    def start(self):
-        # Clear any errors from device
-        self._read_reg(0x00) # Read STAT
-        # Initialize chip (so different chip variants work the same way)
-        self._mask_reg(0x06, 0xc003, 0x4000) # MOD1: 42.7us, IIF disable
-        self._mask_reg(0x08, 0x0007, 0x0001) # MOD2: Predict off, autocal=1
-        self._mask_reg(0x0e, 0x0003, 0x0000) # MOD4: IIF mode
-        # Setup starting clock values
-        mcu_clock, chip_clock = self._query_clock()
-        self.last_chip_clock = chip_clock
-        self.last_chip_mcu_clock = mcu_clock
-        self.chip_freq = float(1<<5) / self.mcu.seconds_to_clock(1. / 750000.)
-        self.update_clock()
-    cmd_ANGLE_DEBUG_READ_help = "Query low-level angle sensor register"
-    def cmd_ANGLE_DEBUG_READ(self, gcmd):
-        reg = gcmd.get("REG", minval=0, maxval=0x30, parser=lambda x: int(x, 0))
-        val = self._read_reg(reg)
-        gcmd.respond_info("ANGLE REG[0x%02x] = 0x%04x" % (reg, val))
-    cmd_ANGLE_DEBUG_WRITE_help = "Set low-level angle sensor register"
-    def cmd_ANGLE_DEBUG_WRITE(self, gcmd):
-        reg = gcmd.get("REG", minval=0, maxval=0x30, parser=lambda x: int(x, 0))
-        val = gcmd.get("VAL", minval=0, maxval=0xffff,
-                       parser=lambda x: int(x, 0))
-        self._write_reg(reg, val)
-
-SAMPLE_PERIOD = 0.000400
-
-class Angle:
-    def __init__(self, config):
-        self.printer = config.get_printer()
-        self.sample_period = config.getfloat('sample_period', SAMPLE_PERIOD,
-                                             above=0.)
-        self.calibration = AngleCalibration(config)
-        # Measurement conversion
-        self.start_clock = self.time_shift = self.sample_ticks = 0
-        self.last_sequence = self.last_angle = 0
-        # Measurement storage (accessed from background thread)
-        self.lock = threading.Lock()
-        self.raw_samples = []
-        # Sensor type
-        sensors = { "a1333": HelperA1333, "as5047d": HelperAS5047D,
-                    "tle5012b": HelperTLE5012B }
-        sensor_type = config.getchoice('sensor_type', {s: s for s in sensors})
-        sensor_class = sensors[sensor_type]
-        self.spi = bus.MCU_SPI_from_config(config, sensor_class.SPI_MODE,
-                                           default_speed=sensor_class.SPI_SPEED)
-        self.mcu = mcu = self.spi.get_mcu()
-        self.oid = oid = mcu.create_oid()
-        self.sensor_helper = sensor_class(config, self.spi, oid)
-        # Setup mcu sensor_spi_angle bulk query code
-        self.query_spi_angle_cmd = self.query_spi_angle_end_cmd = None
-        mcu.add_config_cmd(
-            "config_spi_angle oid=%d spi_oid=%d spi_angle_type=%s"
-            % (oid, self.spi.get_oid(), sensor_type))
-        mcu.add_config_cmd(
-            "query_spi_angle oid=%d clock=0 rest_ticks=0 time_shift=0"
-            % (oid,), on_restart=True)
-        mcu.register_config_callback(self._build_config)
-        mcu.register_response(self._handle_spi_angle_data,
-                              "spi_angle_data", oid)
-        # API server endpoints
-        self.api_dump = motion_report.APIDumpHelper(
-            self.printer, self._api_update, self._api_startstop, 0.100)
-        self.name = config.get_name().split()[1]
-        wh = self.printer.lookup_object('webhooks')
-        wh.register_mux_endpoint("angle/dump_angle", "sensor", self.name,
-                                 self._handle_dump_angle)
-    def _build_config(self):
-        freq = self.mcu.seconds_to_clock(1.)
-        while float(TCODE_ERROR << self.time_shift) / freq < 0.002:
-            self.time_shift += 1
-        cmdqueue = self.spi.get_command_queue()
-        self.query_spi_angle_cmd = self.mcu.lookup_command(
-            "query_spi_angle oid=%c clock=%u rest_ticks=%u time_shift=%c",
-            cq=cmdqueue)
-        self.query_spi_angle_end_cmd = self.mcu.lookup_query_command(
-            "query_spi_angle oid=%c clock=%u rest_ticks=%u time_shift=%c",
-            "spi_angle_end oid=%c sequence=%hu", oid=self.oid, cq=cmdqueue)
-    def get_status(self, eventtime=None):
-        return {'temperature': self.sensor_helper.last_temperature}
-    # Measurement collection
-    def is_measuring(self):
-        return self.start_clock != 0
-    def _handle_spi_angle_data(self, params):
-        with self.lock:
-            self.raw_samples.append(params)
-    def _extract_samples(self, raw_samples):
-        # Load variables to optimize inner loop below
-        sample_ticks = self.sample_ticks
-        start_clock = self.start_clock
-        clock_to_print_time = self.mcu.clock_to_print_time
-        last_sequence = self.last_sequence
-        last_angle = self.last_angle
-        time_shift = 0
-        static_delay = 0.
-        last_chip_mcu_clock = last_chip_clock = chip_freq = inv_chip_freq = 0.
-        is_tcode_absolute = self.sensor_helper.is_tcode_absolute
-        if is_tcode_absolute:
-            tparams = self.sensor_helper.get_tcode_params()
-            last_chip_mcu_clock, last_chip_clock, chip_freq = tparams
-            inv_chip_freq = 1. / chip_freq
-        else:
-            time_shift = self.time_shift
-            static_delay = self.sensor_helper.get_static_delay()
-        # Process every message in raw_samples
-        count = error_count = 0
-        samples = [None] * (len(raw_samples) * 16)
-        for params in raw_samples:
-            seq = (last_sequence & ~0xffff) | params['sequence']
-            if seq < last_sequence:
-                seq += 0x10000
-            last_sequence = seq
-            d = bytearray(params['data'])
-            msg_mclock = start_clock + seq*16*sample_ticks
-            for i in range(len(d) // 3):
-                tcode = d[i*3]
-                if tcode == TCODE_ERROR:
-                    error_count += 1
-                    continue
-                raw_angle = d[i*3 + 1] | (d[i*3 + 2] << 8)
-                angle_diff = (last_angle - raw_angle) & 0xffff
-                angle_diff -= (angle_diff & 0x8000) << 1
-                last_angle -= angle_diff
-                mclock = msg_mclock + i*sample_ticks
-                if is_tcode_absolute:
-                    # tcode is tle5012b frame counter
-                    mdiff = mclock - last_chip_mcu_clock
-                    chip_mclock = last_chip_clock + int(mdiff * chip_freq + .5)
-                    cdiff = ((tcode << 10) - chip_mclock) & 0xffff
-                    cdiff -= (cdiff & 0x8000) << 1
-                    sclock = mclock + (cdiff - 0x800) * inv_chip_freq
-                else:
-                    # tcode is mcu clock offset shifted by time_shift
-                    sclock = mclock + (tcode<<time_shift)
-                ptime = round(clock_to_print_time(sclock) - static_delay, 6)
-                samples[count] = (ptime, last_angle)
-                count += 1
-        self.last_sequence = last_sequence
-        self.last_angle = last_angle
-        del samples[count:]
-        return samples, error_count
-    # API interface
-    def _api_update(self, eventtime):
-        if self.sensor_helper.is_tcode_absolute:
-            self.sensor_helper.update_clock()
-        with self.lock:
-            raw_samples = self.raw_samples
-            self.raw_samples = []
-        if not raw_samples:
-            return {}
-        samples, error_count = self._extract_samples(raw_samples)
-        if not samples:
-            return {}
-        offset = self.calibration.apply_calibration(samples)
-        return {'data': samples, 'errors': error_count,
-                'position_offset': offset}
-    def _start_measurements(self):
-        if self.is_measuring():
-            return
-        logging.info("Starting angle '%s' measurements", self.name)
-        self.sensor_helper.start()
-        # Start bulk reading
-        with self.lock:
-            self.raw_samples = []
-        self.last_sequence = 0
-        systime = self.printer.get_reactor().monotonic()
-        print_time = self.mcu.estimated_print_time(systime) + MIN_MSG_TIME
-        self.start_clock = reqclock = self.mcu.print_time_to_clock(print_time)
-        rest_ticks = self.mcu.seconds_to_clock(self.sample_period)
-        self.sample_ticks = rest_ticks
-        self.query_spi_angle_cmd.send([self.oid, reqclock, rest_ticks,
-                                       self.time_shift], reqclock=reqclock)
-    def _finish_measurements(self):
-        if not self.is_measuring():
-            return
-        # Halt bulk reading
-        params = self.query_spi_angle_end_cmd.send([self.oid, 0, 0, 0])
-        self.start_clock = 0
-        with self.lock:
-            self.raw_samples = []
-        self.sensor_helper.last_temperature = None
-        logging.info("Stopped angle '%s' measurements", self.name)
-    def _api_startstop(self, is_start):
-        if is_start:
-            self._start_measurements()
-        else:
-            self._finish_measurements()
-    def _handle_dump_angle(self, web_request):
-        self.api_dump.add_client(web_request)
-        hdr = ('time', 'angle')
-        web_request.send({'header': hdr})
-    def start_internal_client(self):
-        return self.api_dump.add_internal_client()
-
-def load_config_prefix(config):
-    return Angle(config)
+# Support for reading SPI magnetic angle sensors
+#
+# Copyright (C) 2021,2022  Kevin O'Connor <kevin@koconnor.net>
+#
+# This file may be distributed under the terms of the GNU GPLv3 license.
+import logging, math, threading
+from . import bus, motion_report
+
+MIN_MSG_TIME = 0.100
+TCODE_ERROR = 0xff
+
+TRINAMIC_DRIVERS = ["tmc2130", "tmc2208", "tmc2209", "tmc2240", "tmc2660", "tmc5160"]
+
+CALIBRATION_BITS = 6 # 64 entries
+ANGLE_BITS = 16 # angles range from 0..65535
+
+class AngleCalibration:
+    def __init__(self, config):
+        self.printer = config.get_printer()
+        self.name = config.get_name()
+        self.stepper_name = config.get('stepper', None)
+        if self.stepper_name is None:
+            # No calibration
+            return
+        try:
+            import numpy
+        except:
+            raise config.error("Angle calibration requires numpy module")
+        sconfig = config.getsection(self.stepper_name)
+        sconfig.getint('microsteps', note_valid=False)
+        self.tmc_module = self.mcu_stepper = None
+        # Current calibration data
+        self.mcu_pos_offset = None
+        self.angle_phase_offset = 0.
+        self.calibration_reversed = False
+        self.calibration = []
+        cal = config.get('calibrate', None)
+        if cal is not None:
+            data = [d.strip() for d in cal.split(',')]
+            angles = [float(d) for d in data if d]
+            self.load_calibration(angles)
+        # Register commands
+        self.printer.register_event_handler("stepper:sync_mcu_position",
+                                            self.handle_sync_mcu_pos)
+        self.printer.register_event_handler("klippy:connect", self.connect)
+        cname = self.name.split()[-1]
+        gcode = self.printer.lookup_object('gcode')
+        gcode.register_mux_command("ANGLE_CALIBRATE", "CHIP",
+                                   cname, self.cmd_ANGLE_CALIBRATE,
+                                   desc=self.cmd_ANGLE_CALIBRATE_help)
+    def handle_sync_mcu_pos(self, mcu_stepper):
+        if mcu_stepper.get_name() == self.stepper_name:
+            self.mcu_pos_offset = None
+    def calc_mcu_pos_offset(self, sample):
+        # Lookup phase information
+        mcu_phase_offset, phases = self.tmc_module.get_phase_offset()
+        if mcu_phase_offset is None:
+            return
+        # Find mcu position at time of sample
+        angle_time, angle_pos = sample
+        mcu_pos = self.mcu_stepper.get_past_mcu_position(angle_time)
+        # Convert angle_pos to mcu_pos units
+        microsteps, full_steps = self.get_microsteps()
+        angle_to_mcu_pos = full_steps * microsteps / float(1<<ANGLE_BITS)
+        angle_mpos = angle_pos * angle_to_mcu_pos
+        # Calculate adjustment for stepper phases
+        phase_diff = ((angle_mpos + self.angle_phase_offset * angle_to_mcu_pos)
+                      - (mcu_pos + mcu_phase_offset)) % phases
+        if phase_diff > phases//2:
+            phase_diff -= phases
+        # Store final offset
+        self.mcu_pos_offset = mcu_pos - (angle_mpos - phase_diff)
+    def apply_calibration(self, samples):
+        calibration = self.calibration
+        if not calibration:
+            return None
+        calibration_reversed = self.calibration_reversed
+        interp_bits = ANGLE_BITS - CALIBRATION_BITS
+        interp_mask = (1 << interp_bits) - 1
+        interp_round = 1 << (interp_bits - 1)
+        for i, (samp_time, angle) in enumerate(samples):
+            bucket = (angle & 0xffff) >> interp_bits
+            cal1 = calibration[bucket]
+            cal2 = calibration[bucket + 1]
+            adj = (angle & interp_mask) * (cal2 - cal1)
+            adj = cal1 + ((adj + interp_round) >> interp_bits)
+            angle_diff = (angle - adj) & 0xffff
+            angle_diff -= (angle_diff & 0x8000) << 1
+            new_angle = angle - angle_diff
+            if calibration_reversed:
+                new_angle = -new_angle
+            samples[i] = (samp_time, new_angle)
+        if self.mcu_pos_offset is None:
+            self.calc_mcu_pos_offset(samples[0])
+            if self.mcu_pos_offset is None:
+                return None
+        return self.mcu_stepper.mcu_to_commanded_position(self.mcu_pos_offset)
+    def load_calibration(self, angles):
+        # Calculate linear intepolation calibration buckets by solving
+        # linear equations
+        angle_max = 1 << ANGLE_BITS
+        calibration_count = 1 << CALIBRATION_BITS
+        bucket_size = angle_max // calibration_count
+        full_steps = len(angles)
+        nominal_step = float(angle_max) / full_steps
+        self.angle_phase_offset = (angles.index(min(angles)) & 3) * nominal_step
+        self.calibration_reversed = angles[-2] > angles[-1]
+        if self.calibration_reversed:
+            angles = list(reversed(angles))
+        first_step = angles.index(min(angles))
+        angles = angles[first_step:] + angles[:first_step]
+        import numpy
+        eqs = numpy.zeros((full_steps, calibration_count))
+        ans = numpy.zeros((full_steps,))
+        for step, angle in enumerate(angles):
+            int_angle = int(angle + .5) % angle_max
+            bucket = int(int_angle / bucket_size)
+            bucket_start = bucket * bucket_size
+            ang_diff = angle - bucket_start
+            ang_diff_per = ang_diff / bucket_size
+            eq = eqs[step]
+            eq[bucket] = 1. - ang_diff_per
+            eq[(bucket + 1) % calibration_count] = ang_diff_per
+            ans[step] = float(step * nominal_step)
+            if bucket + 1 >= calibration_count:
+                ans[step] -= ang_diff_per * angle_max
+        sol = numpy.linalg.lstsq(eqs, ans, rcond=None)[0]
+        isol = [int(s + .5) for s in sol]
+        self.calibration = isol + [isol[0] + angle_max]
+    def lookup_tmc(self):
+        for driver in TRINAMIC_DRIVERS:
+            driver_name = "%s %s" % (driver, self.stepper_name)
+            module = self.printer.lookup_object(driver_name, None)
+            if module is not None:
+                return module
+        raise self.printer.command_error("Unable to find TMC driver for %s"
+                                         % (self.stepper_name,))
+    def connect(self):
+        self.tmc_module = self.lookup_tmc()
+        fmove = self.printer.lookup_object('force_move')
+        self.mcu_stepper = fmove.lookup_stepper(self.stepper_name)
+    def get_microsteps(self):
+        configfile = self.printer.lookup_object('configfile')
+        sconfig = configfile.get_status(None)['settings']
+        stconfig = sconfig.get(self.stepper_name, {})
+        microsteps = stconfig['microsteps']
+        full_steps = stconfig['full_steps_per_rotation']
+        return microsteps, full_steps
+    def get_stepper_phase(self):
+        mcu_phase_offset, phases = self.tmc_module.get_phase_offset()
+        if mcu_phase_offset is None:
+            raise self.printer.command_error("Driver phase not known for %s"
+                                             % (self.stepper_name,))
+        mcu_pos = self.mcu_stepper.get_mcu_position()
+        return (mcu_pos + mcu_phase_offset) % phases
+    def do_calibration_moves(self):
+        move = self.printer.lookup_object('force_move').manual_move
+        # Start data collection
+        angle_sensor = self.printer.lookup_object(self.name)
+        cconn = angle_sensor.start_internal_client()
+        # Move stepper several turns (to allow internal sensor calibration)
+        microsteps, full_steps = self.get_microsteps()
+        mcu_stepper = self.mcu_stepper
+        step_dist = mcu_stepper.get_step_dist()
+        full_step_dist = step_dist * microsteps
+        rotation_dist = full_steps * full_step_dist
+        align_dist = step_dist * self.get_stepper_phase()
+        move_time = 0.010
+        move_speed = full_step_dist / move_time
+        move(mcu_stepper, -(rotation_dist+align_dist), move_speed)
+        move(mcu_stepper, 2. * rotation_dist, move_speed)
+        move(mcu_stepper, -2. * rotation_dist, move_speed)
+        move(mcu_stepper, .5 * rotation_dist - full_step_dist, move_speed)
+        # Move to each full step position
+        toolhead = self.printer.lookup_object('toolhead')
+        times = []
+        samp_dist = full_step_dist
+        for i in range(2 * full_steps):
+            move(mcu_stepper, samp_dist, move_speed)
+            start_query_time = toolhead.get_last_move_time() + 0.050
+            end_query_time = start_query_time + 0.050
+            times.append((start_query_time, end_query_time))
+            toolhead.dwell(0.150)
+            if i == full_steps-1:
+                # Reverse direction and test each full step again
+                move(mcu_stepper, .5 * rotation_dist, move_speed)
+                move(mcu_stepper, -.5 * rotation_dist + samp_dist, move_speed)
+                samp_dist = -samp_dist
+        move(mcu_stepper, .5*rotation_dist + align_dist, move_speed)
+        toolhead.wait_moves()
+        # Finish data collection
+        cconn.finalize()
+        msgs = cconn.get_messages()
+        # Correlate query responses
+        cal = {}
+        step = 0
+        for msg in msgs:
+            for query_time, pos in msg['params']['data']:
+                # Add to step tracking
+                while step < len(times) and query_time > times[step][1]:
+                    step += 1
+                if step < len(times) and query_time >= times[step][0]:
+                    cal.setdefault(step, []).append(pos)
+        if len(cal) != len(times):
+            raise self.printer.command_error(
+                "Failed calibration - incomplete sensor data")
+        fcal = { i: cal[i] for i in range(full_steps) }
+        rcal = { full_steps-i-1: cal[i+full_steps] for i in range(full_steps) }
+        return fcal, rcal
+    def calc_angles(self, meas):
+        total_count = total_variance = 0
+        angles = {}
+        for step, data in meas.items():
+            count = len(data)
+            angle_avg = float(sum(data)) / count
+            angles[step] = angle_avg
+            total_count += count
+            total_variance += sum([(d - angle_avg)**2 for d in data])
+        return angles, math.sqrt(total_variance / total_count), total_count
+    cmd_ANGLE_CALIBRATE_help = "Calibrate angle sensor to stepper motor"
+    def cmd_ANGLE_CALIBRATE(self, gcmd):
+        # Perform calibration movement and capture
+        old_calibration = self.calibration
+        self.calibration = []
+        try:
+            fcal, rcal = self.do_calibration_moves()
+        finally:
+            self.calibration = old_calibration
+        # Calculate each step position average and variance
+        microsteps, full_steps = self.get_microsteps()
+        fangles, fstd, ftotal = self.calc_angles(fcal)
+        rangles, rstd, rtotal = self.calc_angles(rcal)
+        if (len({a: i for i, a in fangles.items()}) != len(fangles)
+            or len({a: i for i, a in rangles.items()}) != len(rangles)):
+            raise self.printer.command_error(
+                "Failed calibration - sensor not updating for each step")
+        merged = { i: fcal[i] + rcal[i] for i in range(full_steps) }
+        angles, std, total = self.calc_angles(merged)
+        gcmd.respond_info("angle: stddev=%.3f (%.3f forward / %.3f reverse)"
+                          " in %d queries" % (std, fstd, rstd, total))
+        # Order data with lowest/highest magnet position first
+        anglist = [angles[i] % 0xffff for i in range(full_steps)]
+        if angles[0] > angles[1]:
+            first_ang = max(anglist)
+        else:
+            first_ang = min(anglist)
+        first_phase = anglist.index(first_ang) & ~3
+        anglist = anglist[first_phase:] + anglist[:first_phase]
+        # Save results
+        cal_contents = []
+        for i, angle in enumerate(anglist):
+            if not i % 8:
+                cal_contents.append('\n')
+            cal_contents.append("%.1f" % (angle,))
+            cal_contents.append(',')
+        cal_contents.pop()
+        configfile = self.printer.lookup_object('configfile')
+        configfile.remove_section(self.name)
+        configfile.set(self.name, 'calibrate', ''.join(cal_contents))
+
+class HelperA1333:
+    SPI_MODE = 3
+    SPI_SPEED = 10000000
+    def __init__(self, config, spi, oid):
+        self.spi = spi
+        self.is_tcode_absolute = False
+        self.last_temperature = None
+    def get_static_delay(self):
+        return .000001
+    def start(self):
+        # Setup for angle query
+        self.spi.spi_transfer([0x32, 0x00])
+
+class HelperAS5047D:
+    SPI_MODE = 1
+    SPI_SPEED = int(1. / .000000350)
+    def __init__(self, config, spi, oid):
+        self.spi = spi
+        self.is_tcode_absolute = False
+        self.last_temperature = None
+    def get_static_delay(self):
+        return .000100
+    def start(self):
+        # Clear any errors from device
+        self.spi.spi_transfer([0xff, 0xfc]) # Read DIAAGC
+        self.spi.spi_transfer([0x40, 0x01]) # Read ERRFL
+        self.spi.spi_transfer([0xc0, 0x00]) # Read NOP
+
+class HelperTLE5012B:
+    SPI_MODE = 1
+    SPI_SPEED = 4000000
+    def __init__(self, config, spi, oid):
+        self.printer = config.get_printer()
+        self.spi = spi
+        self.oid = oid
+        self.is_tcode_absolute = True
+        self.last_temperature = None
+        self.mcu = spi.get_mcu()
+        self.mcu.register_config_callback(self._build_config)
+        self.spi_angle_transfer_cmd = None
+        self.last_chip_mcu_clock = self.last_chip_clock = 0
+        self.chip_freq = 0.
+        name = config.get_name().split()[-1]
+        gcode = self.printer.lookup_object("gcode")
+        gcode.register_mux_command("ANGLE_DEBUG_READ", "CHIP", name,
+                                   self.cmd_ANGLE_DEBUG_READ,
+                                   desc=self.cmd_ANGLE_DEBUG_READ_help)
+        gcode.register_mux_command("ANGLE_DEBUG_WRITE", "CHIP", name,
+                                   self.cmd_ANGLE_DEBUG_WRITE,
+                                   desc=self.cmd_ANGLE_DEBUG_WRITE_help)
+    def _build_config(self):
+        cmdqueue = self.spi.get_command_queue()
+        self.spi_angle_transfer_cmd = self.mcu.lookup_query_command(
+            "spi_angle_transfer oid=%c data=%*s",
+            "spi_angle_transfer_response oid=%c clock=%u response=%*s",
+            oid=self.oid, cq=cmdqueue)
+    def get_tcode_params(self):
+        return self.last_chip_mcu_clock, self.last_chip_clock, self.chip_freq
+    def _calc_crc(self, data):
+        crc = 0xff
+        for d in data:
+            crc ^= d
+            for i in range(8):
+                if crc & 0x80:
+                    crc = (crc << 1) ^ 0x1d
+                else:
+                    crc <<= 1
+        return (~crc) & 0xff
+    def _send_spi(self, msg):
+        for retry in range(5):
+            if msg[0] & 0x04:
+                params = self.spi_angle_transfer_cmd.send([self.oid, msg])
+            else:
+                params = self.spi.spi_transfer(msg)
+            resp = bytearray(params['response'])
+            crc = self._calc_crc(bytearray(msg[:2]) + resp[2:-2])
+            if crc == resp[-1]:
+                return params
+        raise self.printer.command_error("Unable to query tle5012b chip")
+    def _read_reg(self, reg):
+        cw = 0x8000 | ((reg & 0x3f) << 4) | 0x01
+        if reg >= 0x05 and reg <= 0x11:
+            cw |= 0x5000
+        msg = [cw >> 8, cw & 0xff, 0, 0, 0, 0]
+        params = self._send_spi(msg)
+        resp = bytearray(params['response'])
+        return (resp[2] << 8) | resp[3]
+    def _write_reg(self, reg, val):
+        cw = ((reg & 0x3f) << 4) | 0x01
+        if reg >= 0x05 and reg <= 0x11:
+            cw |= 0x5000
+        msg = [cw >> 8, cw & 0xff, (val >> 8) & 0xff, val & 0xff, 0, 0]
+        for retry in range(5):
+            self._send_spi(msg)
+            rval = self._read_reg(reg)
+            if rval == val:
+                return
+        raise self.printer.command_error("Unable to write to tle5012b chip")
+    def _mask_reg(self, reg, off, on):
+        rval = self._read_reg(reg)
+        self._write_reg(reg, (rval & ~off) | on)
+    def _query_clock(self):
+        # Read frame counter (and normalize to a 16bit counter)
+        msg = [0x84, 0x42, 0, 0, 0, 0, 0, 0] # Read with latch, AREV and FSYNC
+        params = self._send_spi(msg)
+        resp = bytearray(params['response'])
+        mcu_clock = self.mcu.clock32_to_clock64(params['clock'])
+        chip_clock = ((resp[2] & 0x7e) << 9) | ((resp[4] & 0x3e) << 4)
+        # Calculate temperature
+        temper = resp[5] - ((resp[4] & 0x01) << 8)
+        self.last_temperature = (temper + 152) / 2.776
+        return mcu_clock, chip_clock
+    def update_clock(self):
+        mcu_clock, chip_clock = self._query_clock()
+        mdiff = mcu_clock - self.last_chip_mcu_clock
+        chip_mclock = self.last_chip_clock + int(mdiff * self.chip_freq + .5)
+        cdiff = (chip_mclock - chip_clock) & 0xffff
+        cdiff -= (cdiff & 0x8000) << 1
+        new_chip_clock = chip_mclock - cdiff
+        self.chip_freq = float(new_chip_clock - self.last_chip_clock) / mdiff
+        self.last_chip_clock = new_chip_clock
+        self.last_chip_mcu_clock = mcu_clock
+    def start(self):
+        # Clear any errors from device
+        self._read_reg(0x00) # Read STAT
+        # Initialize chip (so different chip variants work the same way)
+        self._mask_reg(0x06, 0xc003, 0x4000) # MOD1: 42.7us, IIF disable
+        self._mask_reg(0x08, 0x0007, 0x0001) # MOD2: Predict off, autocal=1
+        self._mask_reg(0x0e, 0x0003, 0x0000) # MOD4: IIF mode
+        # Setup starting clock values
+        mcu_clock, chip_clock = self._query_clock()
+        self.last_chip_clock = chip_clock
+        self.last_chip_mcu_clock = mcu_clock
+        self.chip_freq = float(1<<5) / self.mcu.seconds_to_clock(1. / 750000.)
+        self.update_clock()
+    cmd_ANGLE_DEBUG_READ_help = "Query low-level angle sensor register"
+    def cmd_ANGLE_DEBUG_READ(self, gcmd):
+        reg = gcmd.get("REG", minval=0, maxval=0x30, parser=lambda x: int(x, 0))
+        val = self._read_reg(reg)
+        gcmd.respond_info("ANGLE REG[0x%02x] = 0x%04x" % (reg, val))
+    cmd_ANGLE_DEBUG_WRITE_help = "Set low-level angle sensor register"
+    def cmd_ANGLE_DEBUG_WRITE(self, gcmd):
+        reg = gcmd.get("REG", minval=0, maxval=0x30, parser=lambda x: int(x, 0))
+        val = gcmd.get("VAL", minval=0, maxval=0xffff,
+                       parser=lambda x: int(x, 0))
+        self._write_reg(reg, val)
+
+SAMPLE_PERIOD = 0.000400
+
+class Angle:
+    def __init__(self, config):
+        self.printer = config.get_printer()
+        self.sample_period = config.getfloat('sample_period', SAMPLE_PERIOD,
+                                             above=0.)
+        self.calibration = AngleCalibration(config)
+        # Measurement conversion
+        self.start_clock = self.time_shift = self.sample_ticks = 0
+        self.last_sequence = self.last_angle = 0
+        # Measurement storage (accessed from background thread)
+        self.lock = threading.Lock()
+        self.raw_samples = []
+        # Sensor type
+        sensors = { "a1333": HelperA1333, "as5047d": HelperAS5047D,
+                    "tle5012b": HelperTLE5012B }
+        sensor_type = config.getchoice('sensor_type', {s: s for s in sensors})
+        sensor_class = sensors[sensor_type]
+        self.spi = bus.MCU_SPI_from_config(config, sensor_class.SPI_MODE,
+                                           default_speed=sensor_class.SPI_SPEED)
+        self.mcu = mcu = self.spi.get_mcu()
+        self.oid = oid = mcu.create_oid()
+        self.sensor_helper = sensor_class(config, self.spi, oid)
+        # Setup mcu sensor_spi_angle bulk query code
+        self.query_spi_angle_cmd = self.query_spi_angle_end_cmd = None
+        mcu.add_config_cmd(
+            "config_spi_angle oid=%d spi_oid=%d spi_angle_type=%s"
+            % (oid, self.spi.get_oid(), sensor_type))
+        mcu.add_config_cmd(
+            "query_spi_angle oid=%d clock=0 rest_ticks=0 time_shift=0"
+            % (oid,), on_restart=True)
+        mcu.register_config_callback(self._build_config)
+        mcu.register_response(self._handle_spi_angle_data,
+                              "spi_angle_data", oid)
+        # API server endpoints
+        self.api_dump = motion_report.APIDumpHelper(
+            self.printer, self._api_update, self._api_startstop, 0.100)
+        self.name = config.get_name().split()[1]
+        wh = self.printer.lookup_object('webhooks')
+        wh.register_mux_endpoint("angle/dump_angle", "sensor", self.name,
+                                 self._handle_dump_angle)
+    def _build_config(self):
+        freq = self.mcu.seconds_to_clock(1.)
+        while float(TCODE_ERROR << self.time_shift) / freq < 0.002:
+            self.time_shift += 1
+        cmdqueue = self.spi.get_command_queue()
+        self.query_spi_angle_cmd = self.mcu.lookup_command(
+            "query_spi_angle oid=%c clock=%u rest_ticks=%u time_shift=%c",
+            cq=cmdqueue)
+        self.query_spi_angle_end_cmd = self.mcu.lookup_query_command(
+            "query_spi_angle oid=%c clock=%u rest_ticks=%u time_shift=%c",
+            "spi_angle_end oid=%c sequence=%hu", oid=self.oid, cq=cmdqueue)
+    def get_status(self, eventtime=None):
+        return {'temperature': self.sensor_helper.last_temperature}
+    # Measurement collection
+    def is_measuring(self):
+        return self.start_clock != 0
+    def _handle_spi_angle_data(self, params):
+        with self.lock:
+            self.raw_samples.append(params)
+    def _extract_samples(self, raw_samples):
+        # Load variables to optimize inner loop below
+        sample_ticks = self.sample_ticks
+        start_clock = self.start_clock
+        clock_to_print_time = self.mcu.clock_to_print_time
+        last_sequence = self.last_sequence
+        last_angle = self.last_angle
+        time_shift = 0
+        static_delay = 0.
+        last_chip_mcu_clock = last_chip_clock = chip_freq = inv_chip_freq = 0.
+        is_tcode_absolute = self.sensor_helper.is_tcode_absolute
+        if is_tcode_absolute:
+            tparams = self.sensor_helper.get_tcode_params()
+            last_chip_mcu_clock, last_chip_clock, chip_freq = tparams
+            inv_chip_freq = 1. / chip_freq
+        else:
+            time_shift = self.time_shift
+            static_delay = self.sensor_helper.get_static_delay()
+        # Process every message in raw_samples
+        count = error_count = 0
+        samples = [None] * (len(raw_samples) * 16)
+        for params in raw_samples:
+            seq = (last_sequence & ~0xffff) | params['sequence']
+            if seq < last_sequence:
+                seq += 0x10000
+            last_sequence = seq
+            d = bytearray(params['data'])
+            msg_mclock = start_clock + seq*16*sample_ticks
+            for i in range(len(d) // 3):
+                tcode = d[i*3]
+                if tcode == TCODE_ERROR:
+                    error_count += 1
+                    continue
+                raw_angle = d[i*3 + 1] | (d[i*3 + 2] << 8)
+                angle_diff = (last_angle - raw_angle) & 0xffff
+                angle_diff -= (angle_diff & 0x8000) << 1
+                last_angle -= angle_diff
+                mclock = msg_mclock + i*sample_ticks
+                if is_tcode_absolute:
+                    # tcode is tle5012b frame counter
+                    mdiff = mclock - last_chip_mcu_clock
+                    chip_mclock = last_chip_clock + int(mdiff * chip_freq + .5)
+                    cdiff = ((tcode << 10) - chip_mclock) & 0xffff
+                    cdiff -= (cdiff & 0x8000) << 1
+                    sclock = mclock + (cdiff - 0x800) * inv_chip_freq
+                else:
+                    # tcode is mcu clock offset shifted by time_shift
+                    sclock = mclock + (tcode<<time_shift)
+                ptime = round(clock_to_print_time(sclock) - static_delay, 6)
+                samples[count] = (ptime, last_angle)
+                count += 1
+        self.last_sequence = last_sequence
+        self.last_angle = last_angle
+        del samples[count:]
+        return samples, error_count
+    # API interface
+    def _api_update(self, eventtime):
+        if self.sensor_helper.is_tcode_absolute:
+            self.sensor_helper.update_clock()
+        with self.lock:
+            raw_samples = self.raw_samples
+            self.raw_samples = []
+        if not raw_samples:
+            return {}
+        samples, error_count = self._extract_samples(raw_samples)
+        if not samples:
+            return {}
+        offset = self.calibration.apply_calibration(samples)
+        return {'data': samples, 'errors': error_count,
+                'position_offset': offset}
+    def _start_measurements(self):
+        if self.is_measuring():
+            return
+        logging.info("Starting angle '%s' measurements", self.name)
+        self.sensor_helper.start()
+        # Start bulk reading
+        with self.lock:
+            self.raw_samples = []
+        self.last_sequence = 0
+        systime = self.printer.get_reactor().monotonic()
+        print_time = self.mcu.estimated_print_time(systime) + MIN_MSG_TIME
+        self.start_clock = reqclock = self.mcu.print_time_to_clock(print_time)
+        rest_ticks = self.mcu.seconds_to_clock(self.sample_period)
+        self.sample_ticks = rest_ticks
+        self.query_spi_angle_cmd.send([self.oid, reqclock, rest_ticks,
+                                       self.time_shift], reqclock=reqclock)
+    def _finish_measurements(self):
+        if not self.is_measuring():
+            return
+        # Halt bulk reading
+        params = self.query_spi_angle_end_cmd.send([self.oid, 0, 0, 0])
+        self.start_clock = 0
+        with self.lock:
+            self.raw_samples = []
+        self.sensor_helper.last_temperature = None
+        logging.info("Stopped angle '%s' measurements", self.name)
+    def _api_startstop(self, is_start):
+        if is_start:
+            self._start_measurements()
+        else:
+            self._finish_measurements()
+    def _handle_dump_angle(self, web_request):
+        self.api_dump.add_client(web_request)
+        hdr = ('time', 'angle')
+        web_request.send({'header': hdr})
+    def start_internal_client(self):
+        return self.api_dump.add_internal_client()
+
+def load_config_prefix(config):
+    return Angle(config)
diff --git i/klippy/extras/endstop_phase.py w/klippy/extras/endstop_phase.py
index bd34ddbe..623910af 100644
--- i/klippy/extras/endstop_phase.py
+++ w/klippy/extras/endstop_phase.py
@@ -1,231 +1,231 @@
-# Endstop accuracy improvement via stepper phase tracking
-#
-# Copyright (C) 2016-2021  Kevin O'Connor <kevin@koconnor.net>
-#
-# This file may be distributed under the terms of the GNU GPLv3 license.
-import math, logging
-import stepper
-
-TRINAMIC_DRIVERS = ["tmc2130", "tmc2208", "tmc2209", "tmc2660", "tmc5160"]
-
-# Calculate the trigger phase of a stepper motor
-class PhaseCalc:
-    def __init__(self, printer, name, phases=None):
-        self.printer = printer
-        self.name = name
-        self.phases = phases
-        self.tmc_module = None
-        # Statistics tracking for ENDSTOP_PHASE_CALIBRATE
-        self.phase_history = self.last_phase = self.last_mcu_position = None
-        self.is_primary = self.stats_only = False
-    def lookup_tmc(self):
-        for driver in TRINAMIC_DRIVERS:
-            driver_name = "%s %s" % (driver, self.name)
-            module = self.printer.lookup_object(driver_name, None)
-            if module is not None:
-                self.tmc_module = module
-                if self.phases is None:
-                    phase_offset, self.phases = module.get_phase_offset()
-                break
-        if self.phases is not None:
-            self.phase_history = [0] * self.phases
-    def convert_phase(self, driver_phase, driver_phases):
-        phases = self.phases
-        return (int(float(driver_phase) / driver_phases * phases + .5) % phases)
-    def calc_phase(self, stepper, trig_mcu_pos):
-        mcu_phase_offset = 0
-        if self.tmc_module is not None:
-            mcu_phase_offset, phases = self.tmc_module.get_phase_offset()
-            if mcu_phase_offset is None:
-                if self.printer.get_start_args().get('debugoutput') is None:
-                    raise self.printer.command_error("Stepper %s phase unknown"
-                                                     % (self.name,))
-                mcu_phase_offset = 0
-        phase = (trig_mcu_pos + mcu_phase_offset) % self.phases
-        self.phase_history[phase] += 1
-        self.last_phase = phase
-        self.last_mcu_position = trig_mcu_pos
-        return phase
-
-# Adjusted endstop trigger positions
-class EndstopPhase:
-    def __init__(self, config):
-        self.printer = config.get_printer()
-        self.name = config.get_name().split()[1]
-        # Obtain step_distance and microsteps from stepper config section
-        sconfig = config.getsection(self.name)
-        rotation_dist, steps_per_rotation = stepper.parse_step_distance(sconfig)
-        self.step_dist = rotation_dist / steps_per_rotation
-        self.phases = sconfig.getint("microsteps", note_valid=False) * 4
-        self.phase_calc = PhaseCalc(self.printer, self.name, self.phases)
-        # Register event handlers
-        self.printer.register_event_handler("klippy:connect",
-                                            self.phase_calc.lookup_tmc)
-        self.printer.register_event_handler("homing:home_rails_end",
-                                            self.handle_home_rails_end)
-        self.printer.load_object(config, "endstop_phase")
-        # Read config
-        self.endstop_phase = None
-        trigger_phase = config.get('trigger_phase', None)
-        if trigger_phase is not None:
-            p, ps = config.getintlist('trigger_phase', sep='/', count=2)
-            if p >= ps:
-                raise config.error("Invalid trigger_phase '%s'"
-                                   % (trigger_phase,))
-            self.endstop_phase = self.phase_calc.convert_phase(p, ps)
-        self.endstop_align_zero = config.getboolean('endstop_align_zero', False)
-        self.endstop_accuracy = config.getfloat('endstop_accuracy', None,
-                                                above=0.)
-        # Determine endstop accuracy
-        if self.endstop_accuracy is None:
-            self.endstop_phase_accuracy = self.phases//2 - 1
-        elif self.endstop_phase is not None:
-            self.endstop_phase_accuracy = int(
-                math.ceil(self.endstop_accuracy * .5 / self.step_dist))
-        else:
-            self.endstop_phase_accuracy = int(
-                math.ceil(self.endstop_accuracy / self.step_dist))
-        if self.endstop_phase_accuracy >= self.phases // 2:
-            raise config.error("Endstop for %s is not accurate enough for"
-                               " stepper phase adjustment" % (self.name,))
-        if self.printer.get_start_args().get('debugoutput') is not None:
-            self.endstop_phase_accuracy = self.phases
-    def align_endstop(self, rail):
-        if not self.endstop_align_zero or self.endstop_phase is None:
-            return 0.
-        # Adjust the endstop position so 0.0 is always at a full step
-        microsteps = self.phases // 4
-        half_microsteps = microsteps // 2
-        phase_offset = (((self.endstop_phase + half_microsteps) % microsteps)
-                        - half_microsteps) * self.step_dist
-        full_step = microsteps * self.step_dist
-        pe = rail.get_homing_info().position_endstop
-        return int(pe / full_step + .5) * full_step - pe + phase_offset
-    def get_homed_offset(self, stepper, trig_mcu_pos):
-        phase = self.phase_calc.calc_phase(stepper, trig_mcu_pos)
-        if self.endstop_phase is None:
-            logging.info("Setting %s endstop phase to %d", self.name, phase)
-            self.endstop_phase = phase
-            return 0.
-        delta = (phase - self.endstop_phase) % self.phases
-        if delta >= self.phases - self.endstop_phase_accuracy:
-            delta -= self.phases
-        elif delta > self.endstop_phase_accuracy:
-            raise self.printer.command_error(
-                "Endstop %s incorrect phase (got %d vs %d)" % (
-                    self.name, phase, self.endstop_phase))
-        return delta * self.step_dist
-    def handle_home_rails_end(self, homing_state, rails):
-        for rail in rails:
-            stepper = rail.get_steppers()[0]
-            if stepper.get_name() == self.name:
-                trig_mcu_pos = homing_state.get_trigger_position(self.name)
-                align = self.align_endstop(rail)
-                offset = self.get_homed_offset(stepper, trig_mcu_pos)
-                homing_state.set_stepper_adjustment(self.name, align + offset)
-                return
-
-# Support for ENDSTOP_PHASE_CALIBRATE command
-class EndstopPhases:
-    def __init__(self, config):
-        self.printer = config.get_printer()
-        self.tracking = {}
-        # Register handlers
-        self.printer.register_event_handler("homing:home_rails_end",
-                                            self.handle_home_rails_end)
-        self.gcode = self.printer.lookup_object('gcode')
-        self.gcode.register_command("ENDSTOP_PHASE_CALIBRATE",
-                                    self.cmd_ENDSTOP_PHASE_CALIBRATE,
-                                    desc=self.cmd_ENDSTOP_PHASE_CALIBRATE_help)
-    def update_stepper(self, stepper, trig_mcu_pos, is_primary):
-        stepper_name = stepper.get_name()
-        phase_calc = self.tracking.get(stepper_name)
-        if phase_calc is None:
-            # Check if stepper has an endstop_phase config section defined
-            mod_name = "endstop_phase %s" % (stepper_name,)
-            m = self.printer.lookup_object(mod_name, None)
-            if m is not None:
-                phase_calc = m.phase_calc
-            else:
-                # Create new PhaseCalc tracker
-                phase_calc = PhaseCalc(self.printer, stepper_name)
-                phase_calc.stats_only = True
-                phase_calc.lookup_tmc()
-            self.tracking[stepper_name] = phase_calc
-        if phase_calc.phase_history is None:
-            return
-        if is_primary:
-            phase_calc.is_primary = True
-        if phase_calc.stats_only:
-            phase_calc.calc_phase(stepper, trig_mcu_pos)
-    def handle_home_rails_end(self, homing_state, rails):
-        for rail in rails:
-            is_primary = True
-            for stepper in rail.get_steppers():
-                sname = stepper.get_name()
-                trig_mcu_pos = homing_state.get_trigger_position(sname)
-                self.update_stepper(stepper, trig_mcu_pos, is_primary)
-                is_primary = False
-    cmd_ENDSTOP_PHASE_CALIBRATE_help = "Calibrate stepper phase"
-    def cmd_ENDSTOP_PHASE_CALIBRATE(self, gcmd):
-        stepper_name = gcmd.get('STEPPER', None)
-        if stepper_name is None:
-            self.report_stats()
-            return
-        phase_calc = self.tracking.get(stepper_name)
-        if phase_calc is None or phase_calc.phase_history is None:
-            raise gcmd.error("Stats not available for stepper %s"
-                             % (stepper_name,))
-        endstop_phase, phases = self.generate_stats(stepper_name, phase_calc)
-        if not phase_calc.is_primary:
-            return
-        configfile = self.printer.lookup_object('configfile')
-        section = 'endstop_phase %s' % (stepper_name,)
-        configfile.remove_section(section)
-        configfile.set(section, "trigger_phase",
-                       "%s/%s" % (endstop_phase, phases))
-        gcmd.respond_info(
-            "The SAVE_CONFIG command will update the printer config\n"
-            "file with these parameters and restart the printer.")
-    def generate_stats(self, stepper_name, phase_calc):
-        phase_history = phase_calc.phase_history
-        wph = phase_history + phase_history
-        count = sum(phase_history)
-        phases = len(phase_history)
-        half_phases = phases // 2
-        res = []
-        for i in range(phases):
-            phase = i + half_phases
-            cost = sum([wph[j] * abs(j-phase) for j in range(i, i+phases)])
-            res.append((cost, phase))
-        res.sort()
-        best = res[0][1]
-        found = [j for j in range(best - half_phases, best + half_phases)
-                 if wph[j]]
-        best_phase = best % phases
-        lo, hi = found[0] % phases, found[-1] % phases
-        self.gcode.respond_info("%s: trigger_phase=%d/%d (range %d to %d)"
-                                % (stepper_name, best_phase, phases, lo, hi))
-        return best_phase, phases
-    def report_stats(self):
-        if not self.tracking:
-            self.gcode.respond_info(
-                "No steppers found. (Be sure to home at least once.)")
-            return
-        for stepper_name in sorted(self.tracking.keys()):
-            phase_calc = self.tracking[stepper_name]
-            if phase_calc is None or not phase_calc.is_primary:
-                continue
-            self.generate_stats(stepper_name, phase_calc)
-    def get_status(self, eventtime):
-        lh = { name: {'phase': pc.last_phase, 'phases': pc.phases,
-                      'mcu_position': pc.last_mcu_position}
-               for name, pc in self.tracking.items()
-               if pc.phase_history is not None }
-        return { 'last_home': lh }
-
-def load_config_prefix(config):
-    return EndstopPhase(config)
-
-def load_config(config):
-    return EndstopPhases(config)
+# Endstop accuracy improvement via stepper phase tracking
+#
+# Copyright (C) 2016-2021  Kevin O'Connor <kevin@koconnor.net>
+#
+# This file may be distributed under the terms of the GNU GPLv3 license.
+import math, logging
+import stepper
+
+TRINAMIC_DRIVERS = ["tmc2130", "tmc2208", "tmc2209", "tmc2240", "tmc2660", "tmc5160"]
+
+# Calculate the trigger phase of a stepper motor
+class PhaseCalc:
+    def __init__(self, printer, name, phases=None):
+        self.printer = printer
+        self.name = name
+        self.phases = phases
+        self.tmc_module = None
+        # Statistics tracking for ENDSTOP_PHASE_CALIBRATE
+        self.phase_history = self.last_phase = self.last_mcu_position = None
+        self.is_primary = self.stats_only = False
+    def lookup_tmc(self):
+        for driver in TRINAMIC_DRIVERS:
+            driver_name = "%s %s" % (driver, self.name)
+            module = self.printer.lookup_object(driver_name, None)
+            if module is not None:
+                self.tmc_module = module
+                if self.phases is None:
+                    phase_offset, self.phases = module.get_phase_offset()
+                break
+        if self.phases is not None:
+            self.phase_history = [0] * self.phases
+    def convert_phase(self, driver_phase, driver_phases):
+        phases = self.phases
+        return (int(float(driver_phase) / driver_phases * phases + .5) % phases)
+    def calc_phase(self, stepper, trig_mcu_pos):
+        mcu_phase_offset = 0
+        if self.tmc_module is not None:
+            mcu_phase_offset, phases = self.tmc_module.get_phase_offset()
+            if mcu_phase_offset is None:
+                if self.printer.get_start_args().get('debugoutput') is None:
+                    raise self.printer.command_error("Stepper %s phase unknown"
+                                                     % (self.name,))
+                mcu_phase_offset = 0
+        phase = (trig_mcu_pos + mcu_phase_offset) % self.phases
+        self.phase_history[phase] += 1
+        self.last_phase = phase
+        self.last_mcu_position = trig_mcu_pos
+        return phase
+
+# Adjusted endstop trigger positions
+class EndstopPhase:
+    def __init__(self, config):
+        self.printer = config.get_printer()
+        self.name = config.get_name().split()[1]
+        # Obtain step_distance and microsteps from stepper config section
+        sconfig = config.getsection(self.name)
+        rotation_dist, steps_per_rotation = stepper.parse_step_distance(sconfig)
+        self.step_dist = rotation_dist / steps_per_rotation
+        self.phases = sconfig.getint("microsteps", note_valid=False) * 4
+        self.phase_calc = PhaseCalc(self.printer, self.name, self.phases)
+        # Register event handlers
+        self.printer.register_event_handler("klippy:connect",
+                                            self.phase_calc.lookup_tmc)
+        self.printer.register_event_handler("homing:home_rails_end",
+                                            self.handle_home_rails_end)
+        self.printer.load_object(config, "endstop_phase")
+        # Read config
+        self.endstop_phase = None
+        trigger_phase = config.get('trigger_phase', None)
+        if trigger_phase is not None:
+            p, ps = config.getintlist('trigger_phase', sep='/', count=2)
+            if p >= ps:
+                raise config.error("Invalid trigger_phase '%s'"
+                                   % (trigger_phase,))
+            self.endstop_phase = self.phase_calc.convert_phase(p, ps)
+        self.endstop_align_zero = config.getboolean('endstop_align_zero', False)
+        self.endstop_accuracy = config.getfloat('endstop_accuracy', None,
+                                                above=0.)
+        # Determine endstop accuracy
+        if self.endstop_accuracy is None:
+            self.endstop_phase_accuracy = self.phases//2 - 1
+        elif self.endstop_phase is not None:
+            self.endstop_phase_accuracy = int(
+                math.ceil(self.endstop_accuracy * .5 / self.step_dist))
+        else:
+            self.endstop_phase_accuracy = int(
+                math.ceil(self.endstop_accuracy / self.step_dist))
+        if self.endstop_phase_accuracy >= self.phases // 2:
+            raise config.error("Endstop for %s is not accurate enough for"
+                               " stepper phase adjustment" % (self.name,))
+        if self.printer.get_start_args().get('debugoutput') is not None:
+            self.endstop_phase_accuracy = self.phases
+    def align_endstop(self, rail):
+        if not self.endstop_align_zero or self.endstop_phase is None:
+            return 0.
+        # Adjust the endstop position so 0.0 is always at a full step
+        microsteps = self.phases // 4
+        half_microsteps = microsteps // 2
+        phase_offset = (((self.endstop_phase + half_microsteps) % microsteps)
+                        - half_microsteps) * self.step_dist
+        full_step = microsteps * self.step_dist
+        pe = rail.get_homing_info().position_endstop
+        return int(pe / full_step + .5) * full_step - pe + phase_offset
+    def get_homed_offset(self, stepper, trig_mcu_pos):
+        phase = self.phase_calc.calc_phase(stepper, trig_mcu_pos)
+        if self.endstop_phase is None:
+            logging.info("Setting %s endstop phase to %d", self.name, phase)
+            self.endstop_phase = phase
+            return 0.
+        delta = (phase - self.endstop_phase) % self.phases
+        if delta >= self.phases - self.endstop_phase_accuracy:
+            delta -= self.phases
+        elif delta > self.endstop_phase_accuracy:
+            raise self.printer.command_error(
+                "Endstop %s incorrect phase (got %d vs %d)" % (
+                    self.name, phase, self.endstop_phase))
+        return delta * self.step_dist
+    def handle_home_rails_end(self, homing_state, rails):
+        for rail in rails:
+            stepper = rail.get_steppers()[0]
+            if stepper.get_name() == self.name:
+                trig_mcu_pos = homing_state.get_trigger_position(self.name)
+                align = self.align_endstop(rail)
+                offset = self.get_homed_offset(stepper, trig_mcu_pos)
+                homing_state.set_stepper_adjustment(self.name, align + offset)
+                return
+
+# Support for ENDSTOP_PHASE_CALIBRATE command
+class EndstopPhases:
+    def __init__(self, config):
+        self.printer = config.get_printer()
+        self.tracking = {}
+        # Register handlers
+        self.printer.register_event_handler("homing:home_rails_end",
+                                            self.handle_home_rails_end)
+        self.gcode = self.printer.lookup_object('gcode')
+        self.gcode.register_command("ENDSTOP_PHASE_CALIBRATE",
+                                    self.cmd_ENDSTOP_PHASE_CALIBRATE,
+                                    desc=self.cmd_ENDSTOP_PHASE_CALIBRATE_help)
+    def update_stepper(self, stepper, trig_mcu_pos, is_primary):
+        stepper_name = stepper.get_name()
+        phase_calc = self.tracking.get(stepper_name)
+        if phase_calc is None:
+            # Check if stepper has an endstop_phase config section defined
+            mod_name = "endstop_phase %s" % (stepper_name,)
+            m = self.printer.lookup_object(mod_name, None)
+            if m is not None:
+                phase_calc = m.phase_calc
+            else:
+                # Create new PhaseCalc tracker
+                phase_calc = PhaseCalc(self.printer, stepper_name)
+                phase_calc.stats_only = True
+                phase_calc.lookup_tmc()
+            self.tracking[stepper_name] = phase_calc
+        if phase_calc.phase_history is None:
+            return
+        if is_primary:
+            phase_calc.is_primary = True
+        if phase_calc.stats_only:
+            phase_calc.calc_phase(stepper, trig_mcu_pos)
+    def handle_home_rails_end(self, homing_state, rails):
+        for rail in rails:
+            is_primary = True
+            for stepper in rail.get_steppers():
+                sname = stepper.get_name()
+                trig_mcu_pos = homing_state.get_trigger_position(sname)
+                self.update_stepper(stepper, trig_mcu_pos, is_primary)
+                is_primary = False
+    cmd_ENDSTOP_PHASE_CALIBRATE_help = "Calibrate stepper phase"
+    def cmd_ENDSTOP_PHASE_CALIBRATE(self, gcmd):
+        stepper_name = gcmd.get('STEPPER', None)
+        if stepper_name is None:
+            self.report_stats()
+            return
+        phase_calc = self.tracking.get(stepper_name)
+        if phase_calc is None or phase_calc.phase_history is None:
+            raise gcmd.error("Stats not available for stepper %s"
+                             % (stepper_name,))
+        endstop_phase, phases = self.generate_stats(stepper_name, phase_calc)
+        if not phase_calc.is_primary:
+            return
+        configfile = self.printer.lookup_object('configfile')
+        section = 'endstop_phase %s' % (stepper_name,)
+        configfile.remove_section(section)
+        configfile.set(section, "trigger_phase",
+                       "%s/%s" % (endstop_phase, phases))
+        gcmd.respond_info(
+            "The SAVE_CONFIG command will update the printer config\n"
+            "file with these parameters and restart the printer.")
+    def generate_stats(self, stepper_name, phase_calc):
+        phase_history = phase_calc.phase_history
+        wph = phase_history + phase_history
+        count = sum(phase_history)
+        phases = len(phase_history)
+        half_phases = phases // 2
+        res = []
+        for i in range(phases):
+            phase = i + half_phases
+            cost = sum([wph[j] * abs(j-phase) for j in range(i, i+phases)])
+            res.append((cost, phase))
+        res.sort()
+        best = res[0][1]
+        found = [j for j in range(best - half_phases, best + half_phases)
+                 if wph[j]]
+        best_phase = best % phases
+        lo, hi = found[0] % phases, found[-1] % phases
+        self.gcode.respond_info("%s: trigger_phase=%d/%d (range %d to %d)"
+                                % (stepper_name, best_phase, phases, lo, hi))
+        return best_phase, phases
+    def report_stats(self):
+        if not self.tracking:
+            self.gcode.respond_info(
+                "No steppers found. (Be sure to home at least once.)")
+            return
+        for stepper_name in sorted(self.tracking.keys()):
+            phase_calc = self.tracking[stepper_name]
+            if phase_calc is None or not phase_calc.is_primary:
+                continue
+            self.generate_stats(stepper_name, phase_calc)
+    def get_status(self, eventtime):
+        lh = { name: {'phase': pc.last_phase, 'phases': pc.phases,
+                      'mcu_position': pc.last_mcu_position}
+               for name, pc in self.tracking.items()
+               if pc.phase_history is not None }
+        return { 'last_home': lh }
+
+def load_config_prefix(config):
+    return EndstopPhase(config)
+
+def load_config(config):
+    return EndstopPhases(config)
diff --git i/klippy/extras/force_move.py w/klippy/extras/force_move.py
index 3c05843b..d8301b87 100644
--- i/klippy/extras/force_move.py
+++ w/klippy/extras/force_move.py
@@ -43,12 +43,12 @@ class ForceMove:
         gcode = self.printer.lookup_object('gcode')
         gcode.register_command('STEPPER_BUZZ', self.cmd_STEPPER_BUZZ,
                                desc=self.cmd_STEPPER_BUZZ_help)
+        gcode.register_command('SET_KINEMATIC_POSITION',
+                                   self.cmd_SET_KINEMATIC_POSITION,
+                                   desc=self.cmd_SET_KINEMATIC_POSITION_help)
         if config.getboolean("enable_force_move", False):
             gcode.register_command('FORCE_MOVE', self.cmd_FORCE_MOVE,
                                    desc=self.cmd_FORCE_MOVE_help)
-            gcode.register_command('SET_KINEMATIC_POSITION',
-                                   self.cmd_SET_KINEMATIC_POSITION,
-                                   desc=self.cmd_SET_KINEMATIC_POSITION_help)
     def register_stepper(self, config, mcu_stepper):
         self.steppers[mcu_stepper.get_name()] = mcu_stepper
     def lookup_stepper(self, name):
@@ -131,6 +131,7 @@ class ForceMove:
         z = gcmd.get_float('Z', curpos[2])
         logging.info("SET_KINEMATIC_POSITION pos=%.3f,%.3f,%.3f", x, y, z)
         toolhead.set_position([x, y, z, curpos[3]], homing_axes=(0, 1, 2))
+    
 
 def load_config(config):
     return ForceMove(config)
diff --git i/klippy/extras/probe.py w/klippy/extras/probe.py
index 4a32a300..a3247757 100644
--- i/klippy/extras/probe.py
+++ w/klippy/extras/probe.py
@@ -127,6 +127,14 @@ class PrinterProbe:
             if "Timeout during endstop homing" in reason:
                 reason += HINT_TIMEOUT
             raise self.printer.command_error(reason)
+        # get z compensation from x_twist
+        # x_twist module checks if it is enabled, returns 0 compensation if not
+        x_twist_compensation = self.printer.lookup_object(
+            'x_twist_compensation', None)
+        z_compensation = 0 if not x_twist_compensation \
+            else x_twist_compensation.get_z_compensation_value(pos[0])
+        # add z compensation to probe position
+        epos[2] += z_compensation
         self.gcode.respond_info("probe at %.3f,%.3f is z=%.6f"
                                 % (epos[0], epos[1], epos[2]))
         return epos[:3]
@@ -196,7 +204,10 @@ class PrinterProbe:
         gcmd.respond_info("probe: %s" % (["open", "TRIGGERED"][not not res],))
     def get_status(self, eventtime):
         return {'last_query': self.last_state,
-                'last_z_result': self.last_z_result}
+                'last_z_result': self.last_z_result,
+                'x_offset': self.x_offset,
+                'y_offset': self.y_offset,
+                'z_offset': self.z_offset}
     cmd_PROBE_ACCURACY_help = "Probe Z-height accuracy at current XY position"
     def cmd_PROBE_ACCURACY(self, gcmd):
         speed = gcmd.get_float("PROBE_SPEED", self.speed, above=0.)
@@ -248,7 +259,8 @@ class PrinterProbe:
             "The SAVE_CONFIG command will update the printer config file\n"
             "with the above and restart the printer." % (self.name, z_offset))
         configfile = self.printer.lookup_object('configfile')
-        configfile.set(self.name, 'z_offset', "%.3f" % (z_offset,))
+        # configfile.set(self.name, 'z_offset', "%.3f" % (z_offset,))
+        configfile.set(self.name, 'z_offset', "%.3f" % (0.000,))
     cmd_PROBE_CALIBRATE_help = "Calibrate the probe's z_offset"
     def cmd_PROBE_CALIBRATE(self, gcmd):
         manual_probe.verify_no_manual_probe(self.printer)
@@ -262,7 +274,8 @@ class PrinterProbe:
         # Move the nozzle over the probe point
         curpos[0] += self.x_offset
         curpos[1] += self.y_offset
-        self._move(curpos, self.speed)
+        #PwAddNew
+        self._move(curpos,80.)
         # Start manual probe
         manual_probe.ManualProbeHelper(self.printer, gcmd,
                                        self.probe_calibrate_finalize)
diff --git i/klippy/extras/spi_temperature.py w/klippy/extras/spi_temperature.py
index 1a45a624..3972072c 100644
--- i/klippy/extras/spi_temperature.py
+++ w/klippy/extras/spi_temperature.py
@@ -216,7 +216,7 @@ class MAX31855(SensorBase):
 ######################################################################
 
 MAX6675_SCALE = 3
-MAX6675_MULT = 0.25
+MAX6675_MULT = 0.25 * 0.95
 
 class MAX6675(SensorBase):
     def __init__(self, config):
diff --git i/klippy/extras/tmc.py w/klippy/extras/tmc.py
index 18aad419..54279736 100644
--- i/klippy/extras/tmc.py
+++ w/klippy/extras/tmc.py
@@ -1,537 +1,560 @@
-# Common helper code for TMC stepper drivers
-#
-# Copyright (C) 2018-2020  Kevin O'Connor <kevin@koconnor.net>
-#
-# This file may be distributed under the terms of the GNU GPLv3 license.
-import logging, collections
-import stepper
-
-
-######################################################################
-# Field helpers
-######################################################################
-
-# Return the position of the first bit set in a mask
-def ffs(mask):
-    return (mask & -mask).bit_length() - 1
-
-class FieldHelper:
-    def __init__(self, all_fields, signed_fields=[], field_formatters={},
-                 registers=None):
-        self.all_fields = all_fields
-        self.signed_fields = {sf: 1 for sf in signed_fields}
-        self.field_formatters = field_formatters
-        self.registers = registers
-        if self.registers is None:
-            self.registers = collections.OrderedDict()
-        self.field_to_register = { f: r for r, fields in self.all_fields.items()
-                                   for f in fields }
-    def lookup_register(self, field_name, default=None):
-        return self.field_to_register.get(field_name, default)
-    def get_field(self, field_name, reg_value=None, reg_name=None):
-        # Returns value of the register field
-        if reg_name is None:
-            reg_name = self.field_to_register[field_name]
-        if reg_value is None:
-            reg_value = self.registers.get(reg_name, 0)
-        mask = self.all_fields[reg_name][field_name]
-        field_value = (reg_value & mask) >> ffs(mask)
-        if field_name in self.signed_fields and ((reg_value & mask)<<1) > mask:
-            field_value -= (1 << field_value.bit_length())
-        return field_value
-    def set_field(self, field_name, field_value, reg_value=None, reg_name=None):
-        # Returns register value with field bits filled with supplied value
-        if reg_name is None:
-            reg_name = self.field_to_register[field_name]
-        if reg_value is None:
-            reg_value = self.registers.get(reg_name, 0)
-        mask = self.all_fields[reg_name][field_name]
-        new_value = (reg_value & ~mask) | ((field_value << ffs(mask)) & mask)
-        self.registers[reg_name] = new_value
-        return new_value
-    def set_config_field(self, config, field_name, default):
-        # Allow a field to be set from the config file
-        config_name = "driver_" + field_name.upper()
-        reg_name = self.field_to_register[field_name]
-        mask = self.all_fields[reg_name][field_name]
-        maxval = mask >> ffs(mask)
-        if maxval == 1:
-            val = config.getboolean(config_name, default)
-        elif field_name in self.signed_fields:
-            val = config.getint(config_name, default,
-                                minval=-(maxval//2 + 1), maxval=maxval//2)
-        else:
-            val = config.getint(config_name, default, minval=0, maxval=maxval)
-        return self.set_field(field_name, val)
-    def pretty_format(self, reg_name, reg_value):
-        # Provide a string description of a register
-        reg_fields = self.all_fields.get(reg_name, {})
-        reg_fields = sorted([(mask, name) for name, mask in reg_fields.items()])
-        fields = []
-        for mask, field_name in reg_fields:
-            field_value = self.get_field(field_name, reg_value, reg_name)
-            sval = self.field_formatters.get(field_name, str)(field_value)
-            if sval and sval != "0":
-                fields.append(" %s=%s" % (field_name, sval))
-        return "%-11s %08x%s" % (reg_name + ":", reg_value, "".join(fields))
-    def get_reg_fields(self, reg_name, reg_value):
-        # Provide fields found in a register
-        reg_fields = self.all_fields.get(reg_name, {})
-        return {field_name: self.get_field(field_name, reg_value, reg_name)
-                for field_name, mask in reg_fields.items()}
-
-
-######################################################################
-# Periodic error checking
-######################################################################
-
-class TMCErrorCheck:
-    def __init__(self, config, mcu_tmc):
-        self.printer = config.get_printer()
-        name_parts = config.get_name().split()
-        self.stepper_name = ' '.join(name_parts[1:])
-        self.mcu_tmc = mcu_tmc
-        self.fields = mcu_tmc.get_fields()
-        self.check_timer = None
-        self.last_drv_status = self.last_status = None
-        # Setup for GSTAT query
-        reg_name = self.fields.lookup_register("drv_err")
-        if reg_name is not None:
-            self.gstat_reg_info = [0, reg_name, 0xffffffff, 0xffffffff, 0]
-        else:
-            self.gstat_reg_info = None
-        self.clear_gstat = True
-        # Setup for DRV_STATUS query
-        self.irun_field = "irun"
-        reg_name = "DRV_STATUS"
-        mask = err_mask = cs_actual_mask = 0
-        if name_parts[0] == 'tmc2130':
-            # TMC2130 driver quirks
-            self.clear_gstat = False
-            cs_actual_mask = self.fields.all_fields[reg_name]["cs_actual"]
-        elif name_parts[0] == 'tmc2660':
-            # TMC2660 driver quirks
-            self.irun_field = "cs"
-            reg_name = "READRSP@RDSEL2"
-            cs_actual_mask = self.fields.all_fields[reg_name]["se"]
-        err_fields = ["ot", "s2ga", "s2gb", "s2vsa", "s2vsb"]
-        warn_fields = ["otpw", "t120", "t143", "t150", "t157"]
-        for f in err_fields + warn_fields:
-            if f in self.fields.all_fields[reg_name]:
-                mask |= self.fields.all_fields[reg_name][f]
-                if f in err_fields:
-                    err_mask |= self.fields.all_fields[reg_name][f]
-        self.drv_status_reg_info = [0, reg_name, mask, err_mask, cs_actual_mask]
-    def _query_register(self, reg_info, try_clear=False):
-        last_value, reg_name, mask, err_mask, cs_actual_mask = reg_info
-        cleared_flags = 0
-        count = 0
-        while 1:
-            try:
-                val = self.mcu_tmc.get_register(reg_name)
-            except self.printer.command_error as e:
-                count += 1
-                if count < 3 and str(e).startswith("Unable to read tmc uart"):
-                    # Allow more retries on a TMC UART read error
-                    reactor = self.printer.get_reactor()
-                    reactor.pause(reactor.monotonic() + 0.050)
-                    continue
-                raise
-            if val & mask != last_value & mask:
-                fmt = self.fields.pretty_format(reg_name, val)
-                logging.info("TMC '%s' reports %s", self.stepper_name, fmt)
-            reg_info[0] = last_value = val
-            if not val & err_mask:
-                if not cs_actual_mask or val & cs_actual_mask:
-                    break
-                irun = self.fields.get_field(self.irun_field)
-                if self.check_timer is None or irun < 4:
-                    break
-                if (self.irun_field == "irun"
-                    and not self.fields.get_field("ihold")):
-                    break
-                # CS_ACTUAL field of zero - indicates a driver reset
-            count += 1
-            if count >= 3:
-                fmt = self.fields.pretty_format(reg_name, val)
-                raise self.printer.command_error("TMC '%s' reports error: %s"
-                                                 % (self.stepper_name, fmt))
-            if try_clear and val & err_mask:
-                try_clear = False
-                cleared_flags |= val & err_mask
-                self.mcu_tmc.set_register(reg_name, val & err_mask)
-        return cleared_flags
-    def _do_periodic_check(self, eventtime):
-        try:
-            self._query_register(self.drv_status_reg_info)
-            if self.gstat_reg_info is not None:
-                self._query_register(self.gstat_reg_info)
-        except self.printer.command_error as e:
-            self.printer.invoke_shutdown(str(e))
-            return self.printer.get_reactor().NEVER
-        return eventtime + 1.
-    def stop_checks(self):
-        if self.check_timer is None:
-            return
-        self.printer.get_reactor().unregister_timer(self.check_timer)
-        self.check_timer = None
-    def start_checks(self):
-        if self.check_timer is not None:
-            self.stop_checks()
-        cleared_flags = 0
-        self._query_register(self.drv_status_reg_info)
-        if self.gstat_reg_info is not None:
-            cleared_flags = self._query_register(self.gstat_reg_info,
-                                                 try_clear=self.clear_gstat)
-        reactor = self.printer.get_reactor()
-        curtime = reactor.monotonic()
-        self.check_timer = reactor.register_timer(self._do_periodic_check,
-                                                  curtime + 1.)
-        if cleared_flags:
-            reset_mask = self.fields.all_fields["GSTAT"]["reset"]
-            if cleared_flags & reset_mask:
-                return True
-        return False
-    def get_status(self, eventtime=None):
-        if self.check_timer is None:
-            return {'drv_status': None}
-        last_value, reg_name = self.drv_status_reg_info[:2]
-        if last_value != self.last_drv_status:
-            self.last_drv_status = last_value
-            fields = self.fields.get_reg_fields(reg_name, last_value)
-            fields = {n: v for n, v in fields.items() if v}
-            self.last_status = {'drv_status': fields}
-        return self.last_status
-
-
-######################################################################
-# G-Code command helpers
-######################################################################
-
-class TMCCommandHelper:
-    def __init__(self, config, mcu_tmc, current_helper):
-        self.printer = config.get_printer()
-        self.stepper_name = ' '.join(config.get_name().split()[1:])
-        self.name = config.get_name().split()[-1]
-        self.mcu_tmc = mcu_tmc
-        self.current_helper = current_helper
-        self.echeck_helper = TMCErrorCheck(config, mcu_tmc)
-        self.fields = mcu_tmc.get_fields()
-        self.read_registers = self.read_translate = None
-        self.toff = None
-        self.mcu_phase_offset = None
-        self.stepper = None
-        self.stepper_enable = self.printer.load_object(config, "stepper_enable")
-        self.printer.register_event_handler("stepper:sync_mcu_position",
-                                            self._handle_sync_mcu_pos)
-        self.printer.register_event_handler("stepper:set_sdir_inverted",
-                                            self._handle_sync_mcu_pos)
-        self.printer.register_event_handler("klippy:mcu_identify",
-                                            self._handle_mcu_identify)
-        self.printer.register_event_handler("klippy:connect",
-                                            self._handle_connect)
-        # Set microstep config options
-        TMCMicrostepHelper(config, mcu_tmc)
-        # Register commands
-        gcode = self.printer.lookup_object("gcode")
-        gcode.register_mux_command("SET_TMC_FIELD", "STEPPER", self.name,
-                                   self.cmd_SET_TMC_FIELD,
-                                   desc=self.cmd_SET_TMC_FIELD_help)
-        gcode.register_mux_command("INIT_TMC", "STEPPER", self.name,
-                                   self.cmd_INIT_TMC,
-                                   desc=self.cmd_INIT_TMC_help)
-        gcode.register_mux_command("SET_TMC_CURRENT", "STEPPER", self.name,
-                                   self.cmd_SET_TMC_CURRENT,
-                                   desc=self.cmd_SET_TMC_CURRENT_help)
-    def _init_registers(self, print_time=None):
-        # Send registers
-        for reg_name, val in self.fields.registers.items():
-            self.mcu_tmc.set_register(reg_name, val, print_time)
-    cmd_INIT_TMC_help = "Initialize TMC stepper driver registers"
-    def cmd_INIT_TMC(self, gcmd):
-        logging.info("INIT_TMC %s", self.name)
-        print_time = self.printer.lookup_object('toolhead').get_last_move_time()
-        self._init_registers(print_time)
-    cmd_SET_TMC_FIELD_help = "Set a register field of a TMC driver"
-    def cmd_SET_TMC_FIELD(self, gcmd):
-        field_name = gcmd.get('FIELD').lower()
-        reg_name = self.fields.lookup_register(field_name, None)
-        if reg_name is None:
-            raise gcmd.error("Unknown field name '%s'" % (field_name,))
-        value = gcmd.get_int('VALUE')
-        reg_val = self.fields.set_field(field_name, value)
-        print_time = self.printer.lookup_object('toolhead').get_last_move_time()
-        self.mcu_tmc.set_register(reg_name, reg_val, print_time)
-    cmd_SET_TMC_CURRENT_help = "Set the current of a TMC driver"
-    def cmd_SET_TMC_CURRENT(self, gcmd):
-        ch = self.current_helper
-        prev_cur, prev_hold_cur, req_hold_cur, max_cur = ch.get_current()
-        run_current = gcmd.get_float('CURRENT', None, minval=0., maxval=max_cur)
-        hold_current = gcmd.get_float('HOLDCURRENT', None,
-                                      above=0., maxval=max_cur)
-        if run_current is not None or hold_current is not None:
-            if run_current is None:
-                run_current = prev_cur
-            if hold_current is None:
-                hold_current = req_hold_cur
-            toolhead = self.printer.lookup_object('toolhead')
-            print_time = toolhead.get_last_move_time()
-            ch.set_current(run_current, hold_current, print_time)
-            prev_cur, prev_hold_cur, req_hold_cur, max_cur = ch.get_current()
-        # Report values
-        if prev_hold_cur is None:
-            gcmd.respond_info("Run Current: %0.2fA" % (prev_cur,))
-        else:
-            gcmd.respond_info("Run Current: %0.2fA Hold Current: %0.2fA"
-                              % (prev_cur, prev_hold_cur))
-    # Stepper phase tracking
-    def _get_phases(self):
-        return (256 >> self.fields.get_field("mres")) * 4
-    def get_phase_offset(self):
-        return self.mcu_phase_offset, self._get_phases()
-    def _query_phase(self):
-        field_name = "mscnt"
-        if self.fields.lookup_register(field_name, None) is None:
-            # TMC2660 uses MSTEP
-            field_name = "mstep"
-        reg = self.mcu_tmc.get_register(self.fields.lookup_register(field_name))
-        return self.fields.get_field(field_name, reg)
-    def _handle_sync_mcu_pos(self, stepper):
-        if stepper.get_name() != self.stepper_name:
-            return
-        try:
-            driver_phase = self._query_phase()
-        except self.printer.command_error as e:
-            logging.info("Unable to obtain tmc %s phase", self.stepper_name)
-            self.mcu_phase_offset = None
-            enable_line = self.stepper_enable.lookup_enable(self.stepper_name)
-            if enable_line.is_motor_enabled():
-                raise
-            return
-        if not stepper.get_dir_inverted()[0]:
-            driver_phase = 1023 - driver_phase
-        phases = self._get_phases()
-        phase = int(float(driver_phase) / 1024 * phases + .5) % phases
-        moff = (phase - stepper.get_mcu_position()) % phases
-        if self.mcu_phase_offset is not None and self.mcu_phase_offset != moff:
-            logging.warning("Stepper %s phase change (was %d now %d)",
-                            self.stepper_name, self.mcu_phase_offset, moff)
-        self.mcu_phase_offset = moff
-    # Stepper enable/disable tracking
-    def _do_enable(self, print_time):
-        try:
-            if self.toff is not None:
-                # Shared enable via comms handling
-                self.fields.set_field("toff", self.toff)
-            self._init_registers()
-            did_reset = self.echeck_helper.start_checks()
-            if did_reset:
-                self.mcu_phase_offset = None
-            # Calculate phase offset
-            if self.mcu_phase_offset is not None:
-                return
-            gcode = self.printer.lookup_object("gcode")
-            with gcode.get_mutex():
-                if self.mcu_phase_offset is not None:
-                    return
-                logging.info("Pausing toolhead to calculate %s phase offset",
-                             self.stepper_name)
-                self.printer.lookup_object('toolhead').wait_moves()
-                self._handle_sync_mcu_pos(self.stepper)
-        except self.printer.command_error as e:
-            self.printer.invoke_shutdown(str(e))
-    def _do_disable(self, print_time):
-        try:
-            if self.toff is not None:
-                val = self.fields.set_field("toff", 0)
-                reg_name = self.fields.lookup_register("toff")
-                self.mcu_tmc.set_register(reg_name, val, print_time)
-            self.echeck_helper.stop_checks()
-        except self.printer.command_error as e:
-            self.printer.invoke_shutdown(str(e))
-    def _handle_mcu_identify(self):
-        # Lookup stepper object
-        force_move = self.printer.lookup_object("force_move")
-        self.stepper = force_move.lookup_stepper(self.stepper_name)
-        # Note pulse duration and step_both_edge optimizations available
-        self.stepper.setup_default_pulse_duration(.000000100, True)
-    def _handle_stepper_enable(self, print_time, is_enable):
-        if is_enable:
-            cb = (lambda ev: self._do_enable(print_time))
-        else:
-            cb = (lambda ev: self._do_disable(print_time))
-        self.printer.get_reactor().register_callback(cb)
-    def _handle_connect(self):
-        # Check if using step on both edges optimization
-        pulse_duration, step_both_edge = self.stepper.get_pulse_duration()
-        if step_both_edge:
-            self.fields.set_field("dedge", 1)
-        # Check for soft stepper enable/disable
-        enable_line = self.stepper_enable.lookup_enable(self.stepper_name)
-        enable_line.register_state_callback(self._handle_stepper_enable)
-        if not enable_line.has_dedicated_enable():
-            self.toff = self.fields.get_field("toff")
-            self.fields.set_field("toff", 0)
-            logging.info("Enabling TMC virtual enable for '%s'",
-                         self.stepper_name)
-        # Send init
-        try:
-            self._init_registers()
-        except self.printer.command_error as e:
-            logging.info("TMC %s failed to init: %s", self.name, str(e))
-    # get_status information export
-    def get_status(self, eventtime=None):
-        cpos = None
-        if self.stepper is not None and self.mcu_phase_offset is not None:
-            cpos = self.stepper.mcu_to_commanded_position(self.mcu_phase_offset)
-        current = self.current_helper.get_current()
-        res = {'mcu_phase_offset': self.mcu_phase_offset,
-               'phase_offset_position': cpos,
-               'run_current': current[0],
-               'hold_current': current[1]}
-        res.update(self.echeck_helper.get_status(eventtime))
-        return res
-    # DUMP_TMC support
-    def setup_register_dump(self, read_registers, read_translate=None):
-        self.read_registers = read_registers
-        self.read_translate = read_translate
-        gcode = self.printer.lookup_object("gcode")
-        gcode.register_mux_command("DUMP_TMC", "STEPPER", self.name,
-                                   self.cmd_DUMP_TMC,
-                                   desc=self.cmd_DUMP_TMC_help)
-    cmd_DUMP_TMC_help = "Read and display TMC stepper driver registers"
-    def cmd_DUMP_TMC(self, gcmd):
-        logging.info("DUMP_TMC %s", self.name)
-        print_time = self.printer.lookup_object('toolhead').get_last_move_time()
-        gcmd.respond_info("========== Write-only registers ==========")
-        for reg_name, val in self.fields.registers.items():
-            if reg_name not in self.read_registers:
-                gcmd.respond_info(self.fields.pretty_format(reg_name, val))
-        gcmd.respond_info("========== Queried registers ==========")
-        for reg_name in self.read_registers:
-            val = self.mcu_tmc.get_register(reg_name)
-            if self.read_translate is not None:
-                reg_name, val = self.read_translate(reg_name, val)
-            gcmd.respond_info(self.fields.pretty_format(reg_name, val))
-
-
-######################################################################
-# TMC virtual pins
-######################################################################
-
-# Helper class for "sensorless homing"
-class TMCVirtualPinHelper:
-    def __init__(self, config, mcu_tmc):
-        self.printer = config.get_printer()
-        self.mcu_tmc = mcu_tmc
-        self.fields = mcu_tmc.get_fields()
-        if self.fields.lookup_register('diag0_stall') is not None:
-            if config.get('diag0_pin', None) is not None:
-                self.diag_pin = config.get('diag0_pin')
-                self.diag_pin_field = 'diag0_stall'
-            else:
-                self.diag_pin = config.get('diag1_pin', None)
-                self.diag_pin_field = 'diag1_stall'
-        else:
-            self.diag_pin = config.get('diag_pin', None)
-            self.diag_pin_field = None
-        self.mcu_endstop = None
-        self.en_pwm = False
-        self.pwmthrs = 0
-        # Register virtual_endstop pin
-        name_parts = config.get_name().split()
-        ppins = self.printer.lookup_object("pins")
-        ppins.register_chip("%s_%s" % (name_parts[0], name_parts[-1]), self)
-    def setup_pin(self, pin_type, pin_params):
-        # Validate pin
-        ppins = self.printer.lookup_object('pins')
-        if pin_type != 'endstop' or pin_params['pin'] != 'virtual_endstop':
-            raise ppins.error("tmc virtual endstop only useful as endstop")
-        if pin_params['invert'] or pin_params['pullup']:
-            raise ppins.error("Can not pullup/invert tmc virtual pin")
-        if self.diag_pin is None:
-            raise ppins.error("tmc virtual endstop requires diag pin config")
-        # Setup for sensorless homing
-        reg = self.fields.lookup_register("en_pwm_mode", None)
-        if reg is None:
-            self.en_pwm = not self.fields.get_field("en_spreadcycle")
-            self.pwmthrs = self.fields.get_field("tpwmthrs")
-        else:
-            self.en_pwm = self.fields.get_field("en_pwm_mode")
-            self.pwmthrs = 0
-        self.printer.register_event_handler("homing:homing_move_begin",
-                                            self.handle_homing_move_begin)
-        self.printer.register_event_handler("homing:homing_move_end",
-                                            self.handle_homing_move_end)
-        self.mcu_endstop = ppins.setup_pin('endstop', self.diag_pin)
-        return self.mcu_endstop
-    def handle_homing_move_begin(self, hmove):
-        if self.mcu_endstop not in hmove.get_mcu_endstops():
-            return
-        reg = self.fields.lookup_register("en_pwm_mode", None)
-        if reg is None:
-            # On "stallguard4" drivers, "stealthchop" must be enabled
-            tp_val = self.fields.set_field("tpwmthrs", 0)
-            self.mcu_tmc.set_register("TPWMTHRS", tp_val)
-            val = self.fields.set_field("en_spreadcycle", 0)
-        else:
-            # On earlier drivers, "stealthchop" must be disabled
-            self.fields.set_field("en_pwm_mode", 0)
-            val = self.fields.set_field(self.diag_pin_field, 1)
-        self.mcu_tmc.set_register("GCONF", val)
-        tc_val = self.fields.set_field("tcoolthrs", 0xfffff)
-        self.mcu_tmc.set_register("TCOOLTHRS", tc_val)
-    def handle_homing_move_end(self, hmove):
-        if self.mcu_endstop not in hmove.get_mcu_endstops():
-            return
-        reg = self.fields.lookup_register("en_pwm_mode", None)
-        if reg is None:
-            tp_val = self.fields.set_field("tpwmthrs", self.pwmthrs)
-            self.mcu_tmc.set_register("TPWMTHRS", tp_val)
-            val = self.fields.set_field("en_spreadcycle", not self.en_pwm)
-        else:
-            self.fields.set_field("en_pwm_mode", self.en_pwm)
-            val = self.fields.set_field(self.diag_pin_field, 0)
-        self.mcu_tmc.set_register("GCONF", val)
-        tc_val = self.fields.set_field("tcoolthrs", 0)
-        self.mcu_tmc.set_register("TCOOLTHRS", tc_val)
-
-
-######################################################################
-# Config reading helpers
-######################################################################
-
-# Helper to configure and query the microstep settings
-def TMCMicrostepHelper(config, mcu_tmc):
-    fields = mcu_tmc.get_fields()
-    stepper_name = " ".join(config.get_name().split()[1:])
-    stepper_config = ms_config = config.getsection(stepper_name)
-    if (stepper_config.get('microsteps', None, note_valid=False) is None
-        and config.get('microsteps', None, note_valid=False) is not None):
-        # Older config format with microsteps in tmc config section
-        ms_config = config
-    steps = {256: 0, 128: 1, 64: 2, 32: 3, 16: 4, 8: 5, 4: 6, 2: 7, 1: 8}
-    mres = ms_config.getchoice('microsteps', steps)
-    fields.set_field("mres", mres)
-    fields.set_field("intpol", config.getboolean("interpolate", True))
-
-# Helper to configure "stealthchop" mode
-def TMCStealthchopHelper(config, mcu_tmc, tmc_freq):
-    fields = mcu_tmc.get_fields()
-    en_pwm_mode = False
-    velocity = config.getfloat('stealthchop_threshold', 0., minval=0.)
-    if velocity:
-        stepper_name = " ".join(config.get_name().split()[1:])
-        sconfig = config.getsection(stepper_name)
-        rotation_dist, steps_per_rotation = stepper.parse_step_distance(sconfig)
-        step_dist = rotation_dist / steps_per_rotation
-        step_dist_256 = step_dist / (1 << fields.get_field("mres"))
-        threshold = int(tmc_freq * step_dist_256 / velocity + .5)
-        fields.set_field("tpwmthrs", max(0, min(0xfffff, threshold)))
-        en_pwm_mode = True
-    reg = fields.lookup_register("en_pwm_mode", None)
-    if reg is not None:
-        fields.set_field("en_pwm_mode", en_pwm_mode)
-    else:
-        # TMC2208 uses en_spreadCycle
-        fields.set_field("en_spreadcycle", not en_pwm_mode)
+# Common helper code for TMC stepper drivers
+#
+# Copyright (C) 2018-2020  Kevin O'Connor <kevin@koconnor.net>
+#
+# This file may be distributed under the terms of the GNU GPLv3 license.
+import logging, collections
+import stepper
+
+
+######################################################################
+# Field helpers
+######################################################################
+
+# Return the position of the first bit set in a mask
+def ffs(mask):
+    return (mask & -mask).bit_length() - 1
+
+class FieldHelper:
+    def __init__(self, all_fields, signed_fields=[], field_formatters={},
+                 registers=None):
+        self.all_fields = all_fields
+        self.signed_fields = {sf: 1 for sf in signed_fields}
+        self.field_formatters = field_formatters
+        self.registers = registers
+        if self.registers is None:
+            self.registers = collections.OrderedDict()
+        self.field_to_register = { f: r for r, fields in self.all_fields.items()
+                                   for f in fields }
+    def lookup_register(self, field_name, default=None):
+        return self.field_to_register.get(field_name, default)
+    def get_field(self, field_name, reg_value=None, reg_name=None):
+        # Returns value of the register field
+        if reg_name is None:
+            reg_name = self.field_to_register[field_name]
+        if reg_value is None:
+            reg_value = self.registers.get(reg_name, 0)
+        mask = self.all_fields[reg_name][field_name]
+        field_value = (reg_value & mask) >> ffs(mask)
+        if field_name in self.signed_fields and ((reg_value & mask)<<1) > mask:
+            field_value -= (1 << field_value.bit_length())
+        return field_value
+    def set_field(self, field_name, field_value, reg_value=None, reg_name=None):
+        # Returns register value with field bits filled with supplied value
+        if reg_name is None:
+            reg_name = self.field_to_register[field_name]
+        if reg_value is None:
+            reg_value = self.registers.get(reg_name, 0)
+        mask = self.all_fields[reg_name][field_name]
+        new_value = (reg_value & ~mask) | ((field_value << ffs(mask)) & mask)
+        self.registers[reg_name] = new_value
+        return new_value
+    def set_config_field(self, config, field_name, default):
+        # Allow a field to be set from the config file
+        config_name = "driver_" + field_name.upper()
+        reg_name = self.field_to_register[field_name]
+        mask = self.all_fields[reg_name][field_name]
+        maxval = mask >> ffs(mask)
+        if maxval == 1:
+            val = config.getboolean(config_name, default)
+        elif field_name in self.signed_fields:
+            val = config.getint(config_name, default,
+                                minval=-(maxval//2 + 1), maxval=maxval//2)
+        else:
+            val = config.getint(config_name, default, minval=0, maxval=maxval)
+        return self.set_field(field_name, val)
+    def pretty_format(self, reg_name, reg_value):
+        # Provide a string description of a register
+        reg_fields = self.all_fields.get(reg_name, {})
+        reg_fields = sorted([(mask, name) for name, mask in reg_fields.items()])
+        fields = []
+        for mask, field_name in reg_fields:
+            field_value = self.get_field(field_name, reg_value, reg_name)
+            sval = self.field_formatters.get(field_name, str)(field_value)
+            if sval and sval != "0":
+                fields.append(" %s=%s" % (field_name, sval))
+        return "%-11s %08x%s" % (reg_name + ":", reg_value, "".join(fields))
+    def get_reg_fields(self, reg_name, reg_value):
+        # Provide fields found in a register
+        reg_fields = self.all_fields.get(reg_name, {})
+        return {field_name: self.get_field(field_name, reg_value, reg_name)
+                for field_name, mask in reg_fields.items()}
+
+
+######################################################################
+# Periodic error checking
+######################################################################
+
+class TMCErrorCheck:
+    def __init__(self, config, mcu_tmc):
+        self.printer = config.get_printer()
+        name_parts = config.get_name().split()
+        self.stepper_name = ' '.join(name_parts[1:])
+        self.mcu_tmc = mcu_tmc
+        self.fields = mcu_tmc.get_fields()
+        self.check_timer = None
+        self.last_drv_status = self.last_status = None
+        # Setup for GSTAT query
+        reg_name = self.fields.lookup_register("drv_err")
+        if reg_name is not None:
+            self.gstat_reg_info = [0, reg_name, 0xffffffff, 0xffffffff, 0]
+        else:
+            self.gstat_reg_info = None
+        self.clear_gstat = True
+        # Setup for DRV_STATUS query
+        self.irun_field = "irun"
+        reg_name = "DRV_STATUS"
+        mask = err_mask = cs_actual_mask = 0
+        if name_parts[0] == 'tmc2130':
+            # TMC2130 driver quirks
+            self.clear_gstat = False
+            cs_actual_mask = self.fields.all_fields[reg_name]["cs_actual"]
+        # elif name_parts[0] == 'tmc2240':
+        #     self.clear_gstat = False
+        #     cs_actual_mask = self.fields.all_fields[reg_name]["cs_actual"]
+        elif name_parts[0] == 'tmc2660':
+            # TMC2660 driver quirks
+            self.irun_field = "cs"
+            reg_name = "READRSP@RDSEL2"
+            cs_actual_mask = self.fields.all_fields[reg_name]["se"]
+        err_fields = ["ot", "s2ga", "s2gb", "s2vsa", "s2vsb"]
+        warn_fields = ["otpw", "t120", "t143", "t150", "t157"]
+        for f in err_fields + warn_fields:
+            if f in self.fields.all_fields[reg_name]:
+                mask |= self.fields.all_fields[reg_name][f]
+                if f in err_fields:
+                    err_mask |= self.fields.all_fields[reg_name][f]
+        self.drv_status_reg_info = [0, reg_name, mask, err_mask, cs_actual_mask]
+    def _query_register(self, reg_info, try_clear=False):
+        last_value, reg_name, mask, err_mask, cs_actual_mask = reg_info
+        cleared_flags = 0
+        count = 0
+        while 1:
+            try:
+                val = self.mcu_tmc.get_register(reg_name)
+            except self.printer.command_error as e:
+                count += 1
+                if count < 3 and str(e).startswith("Unable to read tmc uart"):
+                    # Allow more retries on a TMC UART read error
+                    reactor = self.printer.get_reactor()
+                    reactor.pause(reactor.monotonic() + 0.050)
+                    continue
+                raise
+            if val & mask != last_value & mask:
+                fmt = self.fields.pretty_format(reg_name, val)
+                logging.info("TMC '%s' reports %s", self.stepper_name, fmt)
+            reg_info[0] = last_value = val
+            if not val & err_mask:
+                if not cs_actual_mask or val & cs_actual_mask:
+                    break
+                irun = self.fields.get_field(self.irun_field)
+                if self.check_timer is None or irun < 4:
+                    break
+                if (self.irun_field == "irun"
+                    and not self.fields.get_field("ihold")):
+                    break
+                # CS_ACTUAL field of zero - indicates a driver reset
+            count += 1
+            if count >= 3:
+                fmt = self.fields.pretty_format(reg_name, val)
+                raise self.printer.command_error("TMC '%s' reports error: %s"
+                                                 % (self.stepper_name, fmt))
+            if try_clear and val & err_mask:
+                try_clear = False
+                cleared_flags |= val & err_mask
+                self.mcu_tmc.set_register(reg_name, val & err_mask)
+        return cleared_flags
+    def _do_periodic_check(self, eventtime):
+        try:
+            self._query_register(self.drv_status_reg_info)
+            if self.gstat_reg_info is not None:
+                self._query_register(self.gstat_reg_info)
+        except self.printer.command_error as e:
+            self.printer.invoke_shutdown(str(e))
+            return self.printer.get_reactor().NEVER
+        return eventtime + 1.
+    def stop_checks(self):
+        if self.check_timer is None:
+            return
+        self.printer.get_reactor().unregister_timer(self.check_timer)
+        self.check_timer = None
+    def start_checks(self):
+        if self.check_timer is not None:
+            self.stop_checks()
+        cleared_flags = 0
+        self._query_register(self.drv_status_reg_info)
+        if self.gstat_reg_info is not None:
+            cleared_flags = self._query_register(self.gstat_reg_info,
+                                                 try_clear=self.clear_gstat)
+        reactor = self.printer.get_reactor()
+        curtime = reactor.monotonic()
+        self.check_timer = reactor.register_timer(self._do_periodic_check,
+                                                  curtime + 1.)
+        if cleared_flags:
+            reset_mask = self.fields.all_fields["GSTAT"]["reset"]
+            if cleared_flags & reset_mask:
+                return True
+        return False
+    def get_status(self, eventtime=None):
+        if self.check_timer is None:
+            return {'drv_status': None}
+        last_value, reg_name = self.drv_status_reg_info[:2]
+        if last_value != self.last_drv_status:
+            self.last_drv_status = last_value
+            fields = self.fields.get_reg_fields(reg_name, last_value)
+            fields = {n: v for n, v in fields.items() if v}
+            self.last_status = {'drv_status': fields}
+        return self.last_status
+
+
+######################################################################
+# G-Code command helpers
+######################################################################
+
+class TMCCommandHelper:
+    def __init__(self, config, mcu_tmc, current_helper):
+        self.printer = config.get_printer()
+        self.stepper_name = ' '.join(config.get_name().split()[1:])
+        self.name = config.get_name().split()[-1]
+        self.mcu_tmc = mcu_tmc
+        self.current_helper = current_helper
+        self.echeck_helper = TMCErrorCheck(config, mcu_tmc)
+        self.fields = mcu_tmc.get_fields()
+        self.read_registers = self.read_translate = None
+        self.toff = None
+        self.mcu_phase_offset = None
+        self.stepper = None
+        self.stepper_enable = self.printer.load_object(config, "stepper_enable")
+        self.printer.register_event_handler("stepper:sync_mcu_position",
+                                            self._handle_sync_mcu_pos)
+        self.printer.register_event_handler("stepper:set_sdir_inverted",
+                                            self._handle_sync_mcu_pos)
+        self.printer.register_event_handler("klippy:mcu_identify",
+                                            self._handle_mcu_identify)
+        self.printer.register_event_handler("klippy:connect",
+                                            self._handle_connect)
+        # Set microstep config options
+        TMCMicrostepHelper(config, mcu_tmc)
+        # Register commands
+        gcode = self.printer.lookup_object("gcode")
+        gcode.register_mux_command("SET_TMC_FIELD", "STEPPER", self.name,
+                                   self.cmd_SET_TMC_FIELD,
+                                   desc=self.cmd_SET_TMC_FIELD_help)
+        gcode.register_mux_command("INIT_TMC", "STEPPER", self.name,
+                                   self.cmd_INIT_TMC,
+                                   desc=self.cmd_INIT_TMC_help)
+        gcode.register_mux_command("SET_TMC_CURRENT", "STEPPER", self.name,
+                                   self.cmd_SET_TMC_CURRENT,
+                                   desc=self.cmd_SET_TMC_CURRENT_help)
+    def _init_registers(self, print_time=None):
+        # Send registers
+        for reg_name, val in self.fields.registers.items():
+            self.mcu_tmc.set_register(reg_name, val, print_time)
+    cmd_INIT_TMC_help = "Initialize TMC stepper driver registers"
+    def cmd_INIT_TMC(self, gcmd):
+        logging.info("INIT_TMC %s", self.name)
+        print_time = self.printer.lookup_object('toolhead').get_last_move_time()
+        self._init_registers(print_time)
+    cmd_SET_TMC_FIELD_help = "Set a register field of a TMC driver"
+    def cmd_SET_TMC_FIELD(self, gcmd):
+        field_name = gcmd.get('FIELD').lower()
+        reg_name = self.fields.lookup_register(field_name, None)
+        if reg_name is None:
+            raise gcmd.error("Unknown field name '%s'" % (field_name,))
+        value = gcmd.get_int('VALUE')
+        reg_val = self.fields.set_field(field_name, value)
+        print_time = self.printer.lookup_object('toolhead').get_last_move_time()
+        self.mcu_tmc.set_register(reg_name, reg_val, print_time)
+    cmd_SET_TMC_CURRENT_help = "Set the current of a TMC driver"
+    def cmd_SET_TMC_CURRENT(self, gcmd):
+        ch = self.current_helper
+        prev_cur, prev_hold_cur, req_hold_cur, max_cur = ch.get_current()
+        run_current = gcmd.get_float('CURRENT', None, minval=0., maxval=max_cur)
+        hold_current = gcmd.get_float('HOLDCURRENT', None,
+                                      above=0., maxval=max_cur)
+        if run_current is not None or hold_current is not None:
+            if run_current is None:
+                run_current = prev_cur
+            if hold_current is None:
+                hold_current = req_hold_cur
+            toolhead = self.printer.lookup_object('toolhead')
+            print_time = toolhead.get_last_move_time()
+            ch.set_current(run_current, hold_current, print_time)
+            prev_cur, prev_hold_cur, req_hold_cur, max_cur = ch.get_current()
+        # Report values
+        if prev_hold_cur is None:
+            gcmd.respond_info("Run Current: %0.2fA" % (prev_cur,))
+        else:
+            gcmd.respond_info("Run Current: %0.2fA Hold Current: %0.2fA"
+                              % (prev_cur, prev_hold_cur))
+    # Stepper phase tracking
+    def _get_phases(self):
+        return (256 >> self.fields.get_field("mres")) * 4
+    def get_phase_offset(self):
+        return self.mcu_phase_offset, self._get_phases()
+    def _query_phase(self):
+        field_name = "mscnt"
+        if self.fields.lookup_register(field_name, None) is None:
+            # TMC2660 uses MSTEP
+            field_name = "mstep"
+        reg = self.mcu_tmc.get_register(self.fields.lookup_register(field_name))
+        return self.fields.get_field(field_name, reg)
+    def _handle_sync_mcu_pos(self, stepper):
+        if stepper.get_name() != self.stepper_name:
+            return
+        try:
+            driver_phase = self._query_phase()
+        except self.printer.command_error as e:
+            logging.info("Unable to obtain tmc %s phase", self.stepper_name)
+            self.mcu_phase_offset = None
+            enable_line = self.stepper_enable.lookup_enable(self.stepper_name)
+            if enable_line.is_motor_enabled():
+                raise
+            return
+        if not stepper.get_dir_inverted()[0]:
+            driver_phase = 1023 - driver_phase
+        phases = self._get_phases()
+        phase = int(float(driver_phase) / 1024 * phases + .5) % phases
+        moff = (phase - stepper.get_mcu_position()) % phases
+        if self.mcu_phase_offset is not None and self.mcu_phase_offset != moff:
+            logging.warning("Stepper %s phase change (was %d now %d)",
+                            self.stepper_name, self.mcu_phase_offset, moff)
+        self.mcu_phase_offset = moff
+    # Stepper enable/disable tracking
+    def _do_enable(self, print_time):
+        try:
+            if self.toff is not None:
+                # Shared enable via comms handling
+                self.fields.set_field("toff", self.toff)
+            self._init_registers()
+            did_reset = self.echeck_helper.start_checks()
+            if did_reset:
+                self.mcu_phase_offset = None
+            # Calculate phase offset
+            if self.mcu_phase_offset is not None:
+                return
+            gcode = self.printer.lookup_object("gcode")
+            with gcode.get_mutex():
+                if self.mcu_phase_offset is not None:
+                    return
+                logging.info("Pausing toolhead to calculate %s phase offset",
+                             self.stepper_name)
+                self.printer.lookup_object('toolhead').wait_moves()
+                self._handle_sync_mcu_pos(self.stepper)
+        except self.printer.command_error as e:
+            self.printer.invoke_shutdown(str(e))
+    def _do_disable(self, print_time):
+        try:
+            if self.toff is not None:
+                val = self.fields.set_field("toff", 0)
+                reg_name = self.fields.lookup_register("toff")
+                self.mcu_tmc.set_register(reg_name, val, print_time)
+            self.echeck_helper.stop_checks()
+        except self.printer.command_error as e:
+            self.printer.invoke_shutdown(str(e))
+    def _handle_mcu_identify(self):
+        # Lookup stepper object
+        force_move = self.printer.lookup_object("force_move")
+        self.stepper = force_move.lookup_stepper(self.stepper_name)
+        # Note pulse duration and step_both_edge optimizations available
+        self.stepper.setup_default_pulse_duration(.000000100, True)
+    def _handle_stepper_enable(self, print_time, is_enable):
+        if is_enable:
+            cb = (lambda ev: self._do_enable(print_time))
+        else:
+            cb = (lambda ev: self._do_disable(print_time))
+        self.printer.get_reactor().register_callback(cb)
+    def _handle_connect(self):
+        # Check if using step on both edges optimization
+        pulse_duration, step_both_edge = self.stepper.get_pulse_duration()
+        if step_both_edge:
+            self.fields.set_field("dedge", 1)
+        # Check for soft stepper enable/disable
+        enable_line = self.stepper_enable.lookup_enable(self.stepper_name)
+        enable_line.register_state_callback(self._handle_stepper_enable)
+        if not enable_line.has_dedicated_enable():
+            self.toff = self.fields.get_field("toff")
+            self.fields.set_field("toff", 0)
+            logging.info("Enabling TMC virtual enable for '%s'",
+                         self.stepper_name)
+        # Send init
+        try:
+            self._init_registers()
+        except self.printer.command_error as e:
+            logging.info("TMC %s failed to init: %s", self.name, str(e))
+    # get_status information export
+    def get_status(self, eventtime=None):
+        cpos = None
+        if self.stepper is not None and self.mcu_phase_offset is not None:
+            cpos = self.stepper.mcu_to_commanded_position(self.mcu_phase_offset)
+        current = self.current_helper.get_current()
+        res = {'mcu_phase_offset': self.mcu_phase_offset,
+               'phase_offset_position': cpos,
+               'run_current': current[0],
+               'hold_current': current[1]}
+        res.update(self.echeck_helper.get_status(eventtime))
+        return res
+    # DUMP_TMC support
+    def setup_register_dump(self, read_registers, read_translate=None):
+        self.read_registers = read_registers
+        self.read_translate = read_translate
+        gcode = self.printer.lookup_object("gcode")
+        gcode.register_mux_command("DUMP_TMC", "STEPPER", self.name,
+                                   self.cmd_DUMP_TMC,
+                                   desc=self.cmd_DUMP_TMC_help)
+    cmd_DUMP_TMC_help = "Read and display TMC stepper driver registers"
+    def cmd_DUMP_TMC(self, gcmd):
+        logging.info("DUMP_TMC %s", self.name)
+        print_time = self.printer.lookup_object('toolhead').get_last_move_time()
+        gcmd.respond_info("========== Write-only registers ==========")
+        for reg_name, val in self.fields.registers.items():
+            if reg_name not in self.read_registers:
+                gcmd.respond_info(self.fields.pretty_format(reg_name, val))
+        gcmd.respond_info("========== Queried registers ==========")
+        for reg_name in self.read_registers:
+            val = self.mcu_tmc.get_register(reg_name)
+            if self.read_translate is not None:
+                reg_name, val = self.read_translate(reg_name, val)
+            gcmd.respond_info(self.fields.pretty_format(reg_name, val))
+
+
+######################################################################
+# TMC virtual pins
+######################################################################
+
+# Helper class for "sensorless homing"
+class TMCVirtualPinHelper:
+    def __init__(self, config, mcu_tmc):
+        self.printer = config.get_printer()
+        self.mcu_tmc = mcu_tmc
+        self.fields = mcu_tmc.get_fields()
+        if self.fields.lookup_register('diag0_stall') is not None:
+            if config.get('diag0_pin', None) is not None:
+                self.diag_pin = config.get('diag0_pin')
+                self.diag_pin_field = 'diag0_stall'
+            else:
+                self.diag_pin = config.get('diag1_pin', None)
+                self.diag_pin_field = 'diag1_stall'
+        else:
+            self.diag_pin = config.get('diag_pin', None)
+            self.diag_pin_field = None
+        self.mcu_endstop = None
+        self.en_pwm = False
+        self.pwmthrs = 0
+        # Register virtual_endstop pin
+        name_parts = config.get_name().split()
+        ppins = self.printer.lookup_object("pins")
+        ppins.register_chip("%s_%s" % (name_parts[0], name_parts[-1]), self)
+    def setup_pin(self, pin_type, pin_params):
+        # Validate pin
+        ppins = self.printer.lookup_object('pins')
+        if pin_type != 'endstop' or pin_params['pin'] != 'virtual_endstop':
+            raise ppins.error("tmc virtual endstop only useful as endstop")
+        if pin_params['invert'] or pin_params['pullup']:
+            raise ppins.error("Can not pullup/invert tmc virtual pin")
+        if self.diag_pin is None:
+            raise ppins.error("tmc virtual endstop requires diag pin config")
+        # Setup for sensorless homing
+        reg = self.fields.lookup_register("en_pwm_mode", None)
+        if reg is None:
+            self.en_pwm = not self.fields.get_field("en_spreadcycle")
+            self.pwmthrs = self.fields.get_field("tpwmthrs")
+        else:
+            self.en_pwm = self.fields.get_field("en_pwm_mode")
+            self.pwmthrs = 0
+        self.printer.register_event_handler("homing:homing_move_begin",
+                                            self.handle_homing_move_begin)
+        self.printer.register_event_handler("homing:homing_move_end",
+                                            self.handle_homing_move_end)
+        self.mcu_endstop = ppins.setup_pin('endstop', self.diag_pin)
+        return self.mcu_endstop
+    def handle_homing_move_begin(self, hmove):
+        if self.mcu_endstop not in hmove.get_mcu_endstops():
+            return
+        reg = self.fields.lookup_register("en_pwm_mode", None)
+        if reg is None:
+            logging.info("##############################")
+            # On "stallguard4" drivers, "stealthchop" must be enabled
+            tp_val = self.fields.set_field("tpwmthrs", 0)
+            self.mcu_tmc.set_register("TPWMTHRS", tp_val)
+            val = self.fields.set_field("en_spreadcycle", 0)
+        else:
+            # On earlier drivers, "stealthchop" must be disabled
+            logging.info("******************************")
+            self.fields.set_field("en_pwm_mode", 0)
+            val = self.fields.set_field(self.diag_pin_field, 1)
+        self.mcu_tmc.set_register("GCONF", val)
+        tc_val = self.fields.set_field("tcoolthrs", 0xfffff)
+        self.mcu_tmc.set_register("TCOOLTHRS", tc_val)
+    def handle_homing_move_end(self, hmove):
+        if self.mcu_endstop not in hmove.get_mcu_endstops():
+            return
+        reg = self.fields.lookup_register("en_pwm_mode", None)
+        if reg is None:
+            tp_val = self.fields.set_field("tpwmthrs", self.pwmthrs)
+            self.mcu_tmc.set_register("TPWMTHRS", tp_val)
+            val = self.fields.set_field("en_spreadcycle", not self.en_pwm)
+        else:
+            self.fields.set_field("en_pwm_mode", self.en_pwm)
+            val = self.fields.set_field(self.diag_pin_field, 0)
+        self.mcu_tmc.set_register("GCONF", val)
+        tc_val = self.fields.set_field("tcoolthrs", 0)
+        self.mcu_tmc.set_register("TCOOLTHRS", tc_val)
+
+
+######################################################################
+# Config reading helpers
+######################################################################
+
+# Helper to configure and query the microstep settings
+def TMCMicrostepHelper(config, mcu_tmc):
+    fields = mcu_tmc.get_fields()
+    stepper_name = " ".join(config.get_name().split()[1:])
+    stepper_config = ms_config = config.getsection(stepper_name)
+    if (stepper_config.get('microsteps', None, note_valid=False) is None
+        and config.get('microsteps', None, note_valid=False) is not None):
+        # Older config format with microsteps in tmc config section
+        ms_config = config
+    steps = {256: 0, 128: 1, 64: 2, 32: 3, 16: 4, 8: 5, 4: 6, 2: 7, 1: 8}
+    mres = ms_config.getchoice('microsteps', steps)
+    fields.set_field("mres", mres)
+    fields.set_field("intpol", config.getboolean("interpolate", True))
+
+# Helper to configure "stealthchop" mode
+def TMCStealthchopHelper(config, mcu_tmc, tmc_freq):
+    fields = mcu_tmc.get_fields()
+    en_pwm_mode = False
+    velocity = config.getfloat('stealthchop_threshold', 0., minval=0.)
+    if velocity:
+        stepper_name = " ".join(config.get_name().split()[1:])
+        sconfig = config.getsection(stepper_name)
+        rotation_dist, steps_per_rotation = stepper.parse_step_distance(sconfig)
+        step_dist = rotation_dist / steps_per_rotation
+        step_dist_256 = step_dist / (1 << fields.get_field("mres"))
+        threshold = int(tmc_freq * step_dist_256 / velocity + .5)
+        fields.set_field("tpwmthrs", max(0, min(0xfffff, threshold)))
+        en_pwm_mode = True
+    reg = fields.lookup_register("en_pwm_mode", None)
+    if reg is not None:
+        fields.set_field("en_pwm_mode", en_pwm_mode)
+    else:
+        # TMC2208 uses en_spreadCycle
+        fields.set_field("en_spreadcycle", not en_pwm_mode)
+
+# Helper to configure "stealthchop" mode
+def TMC2240StealthchopHelper(config, mcu_tmc, tmc_freq):
+    fields = mcu_tmc.get_fields()
+    en_pwm_mode = True
+    velocity = config.getfloat('stealthchop_threshold', 0., minval=0.)
+    if velocity:
+        stepper_name = " ".join(config.get_name().split()[1:])
+        sconfig = config.getsection(stepper_name)
+        rotation_dist, steps_per_rotation = stepper.parse_step_distance(sconfig)
+        step_dist = rotation_dist / steps_per_rotation
+        step_dist_256 = step_dist / (1 << fields.get_field("mres"))
+        threshold = int(tmc_freq * step_dist_256 / velocity + .5)
+        fields.set_field("tpwmthrs", max(0, min(0xfffff, threshold)))
+        en_pwm_mode = False
+    reg = fields.lookup_register("en_pwm_mode", None)
+    if reg is not None:
+        fields.set_field("en_pwm_mode", en_pwm_mode)
diff --git i/klippy/extras/virtual_sdcard.py w/klippy/extras/virtual_sdcard.py
index daf19db9..4c019a08 100644
--- i/klippy/extras/virtual_sdcard.py
+++ w/klippy/extras/virtual_sdcard.py
@@ -3,7 +3,9 @@
 # Copyright (C) 2018  Kevin O'Connor <kevin@koconnor.net>
 #
 # This file may be distributed under the terms of the GNU GPLv3 license.
-import os, logging
+import os, sys, logging
+reload(sys)
+sys.setdefaultencoding('utf-8')
 
 VALID_GCODE_EXTS = ['gcode', 'g', 'gco']
 
diff --git i/klippy/gcode.py w/klippy/gcode.py
index 07e312f9..e4f6df5d 100644
--- i/klippy/gcode.py
+++ w/klippy/gcode.py
@@ -106,7 +106,7 @@ class GCodeDispatch:
         self.gcode_help = {}
         # Register commands needed before config file is loaded
         handlers = ['M110', 'M112', 'M115',
-                    'RESTART', 'FIRMWARE_RESTART', 'ECHO', 'STATUS', 'HELP']
+                    'RESTART', 'FIRMWARE_RESTART', 'ECHO', 'STATUS', 'HELP', 'CLOSE_MCU_PORT']
         for cmd in handlers:
             func = getattr(self, 'cmd_' + cmd)
             desc = getattr(self, 'cmd_' + cmd + '_help', None)
@@ -162,7 +162,7 @@ class GCodeDispatch:
         if not self.is_printer_ready:
             return
         self.is_printer_ready = False
-        self.gcode_handlers = self.base_gcode_handlers
+        # self.gcode_handlers = self.base_gcode_handlers
         self._respond_state("Shutdown")
     def _handle_disconnect(self):
         self._respond_state("Disconnect")
@@ -329,6 +329,9 @@ class GCodeDispatch:
     def cmd_RESTART(self, gcmd):
         self.request_restart('restart')
     cmd_FIRMWARE_RESTART_help = "Restart firmware, host, and reload config"
+    def cmd_CLOSE_MCU_PORT(self, gcmd):
+        self.request_restart('close_mcu_port')
+    cmd_CLOSE_MCU_PORT_help = "Close the port of mcu"
     def cmd_FIRMWARE_RESTART(self, gcmd):
         self.request_restart('firmware_restart')
     def cmd_ECHO(self, gcmd):
diff --git i/klippy/klippy.py w/klippy/klippy.py
index dbd3cd37..6e062ea1 100644
--- i/klippy/klippy.py
+++ w/klippy/klippy.py
@@ -233,6 +233,9 @@ class Printer:
             if run_result == 'firmware_restart':
                 for n, m in self.lookup_objects(module='mcu'):
                     m.microcontroller_restart()
+            if run_result == 'close_mcu_port':
+                for n, m in self.lookup_objects(module='mcu'):
+                    m.microcontroller_close_port()
             self.send_event("klippy:disconnect")
         except:
             logging.exception("Unhandled exception during post run")
diff --git i/klippy/mcu.py w/klippy/mcu.py
old mode 100644
new mode 100755
index 3fda90dc..8e7ec3c4
--- i/klippy/mcu.py
+++ w/klippy/mcu.py
@@ -125,7 +125,7 @@ class MCU_trsync:
             s.note_homing_end()
         return params['trigger_reason']
 
-TRSYNC_TIMEOUT = 0.025
+TRSYNC_TIMEOUT = 0.10
 TRSYNC_SINGLE_MCU_TIMEOUT = 0.250
 
 class MCU_endstop:
@@ -458,7 +458,7 @@ class MCU_adc:
 
 # Class to retry sending of a query command until a given response is received
 class RetryAsyncCommand:
-    TIMEOUT_TIME = 5.0
+    TIMEOUT_TIME = 100
     RETRY_TIME = 0.500
     def __init__(self, serial, name, oid=None):
         self.serial = serial
@@ -920,6 +920,9 @@ class MCU:
             self._restart_cheetah()
         else:
             self._restart_arduino()
+    def microcontroller_close_port(self):
+        logging.info("Self define cmd: close Port ")
+        self._disconnect()
     # Misc external commands
     def is_fileoutput(self):
         return self._printer.get_start_args().get('debugoutput') is not None
no changes added to commit (use "git add" and/or "git commit -a")

```
  
</details>
