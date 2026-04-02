#! /bin/bash

# create group
groupadd -g ${ENV_GID} "${ENV_GNAME}"

# create user
useradd -u ${ENV_UID} -g ${ENV_GID} -d "${ENV_HOME}" -s /bin/bash "${ENV_UNAME}"

# change user
exec gosu "${ENV_UNAME}" bash --login -c 'export force_color_prompt=yes && cd "$HOME" && exec "$@"' -- "$@" 

