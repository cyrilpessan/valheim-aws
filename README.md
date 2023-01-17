# valheim-aws

## Configure deployment

deploy/config folder

## start with an existing world

- In the 'template' folder created locally, just put the two world files (.fwl and .db).
- In the .tfvars file, assign the world name to the var 'initial_world_name'.

## Discord bot

To register the Discord bot commands, go to the `/<template folder>/scripts` folder and execute the `register-commands.sh` script (execution permission setup can be needed).
