# Lambda

## Create lamdba layer

- On your own computer, make a new folder somewhere called `python/lib/python3.8/site-packages`. It needs to be called exactly this. I made a folder called temp_folder , and made my `python/lib/python3.8/site-packages` subfolder within it: `mkdir -p temp_folder/python/lib/python3.8/site-packages && cd temp_folder`
- Do a targeted pip install of PyNaCl into the bottom of that folder: `python3 -m pip install PyNaCl -t python/lib/python3.8/site-packages/`
- (Optional) Install zip: `sudo apt install zip`
- Zip up the `python/lib/python3.8/site-packages` folder: `zip -r pynacl_layer.zip *` . We’ll upload this zipped file into AWS so we can import the package.
