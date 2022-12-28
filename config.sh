#!/bin/bash

if [[ -z `which java` ]]; then
    # If the system is debian based
    if [[ -n `which apt` ]]; then 
        echo "Debian based system detected, installing dependencies with apt"
        sudo apt install openjdk-11-jre
    elif [[ -n `which pacman` ]]; then
        echo "Arch based system detected, installing dependencies with pacman"
        sudo pacman -S jre11-openjdk-headless
    else
        echo "Could not detect software manager. Dependencies will need to be installed automatically"
    fi
fi

echo "What server version would you like to use?"
serverJar="https://launcher.mojang.com/v1/objects/a412fd69db1f81db3f511c1463fd304675244077/server.jar"

declare -A versions
versions= # Redacted

select version in `for i in ${!versions[@]}; do echo $i; done | sort -n`; do
    echo "Downloading server $version"
    echo "${versions[$version]}"
    wget -O server.jar "${versions[$version]}"
    break
done

echo -n "Enter server port (default 25565): "
read port
port=${port:-"25565"}

echo -n "Enter max players (default 10): "
read players
players=${players:-"10"}

echo -n "Enter minimum ram usage (default 1): "
read minRam
minRam=${minRam:-"1"}

defaultMaxRam=`free -g | grep Mem | awk '{print $NF}'`
echo -n "Enter minimum ram usage (default $defaultMaxRam): "
read maxRam
maxRam=${maxRam:-"$defaultMaxRam"}

# TODO Advance settings and such like
echo -n "Would you like to configure more settings? [y/N] "
read response
response=${response:-"n"}

mkdir -p world/datapacks

if (echo $response | grep -qPi '^y'); then 

    echo 'Please select any datapacks you would like to add:'
    pushd world/datapacks
    select p in "Capture the Flag" "Tag" "Done"; do
        case $p in
            "Capture the Flag")
                git clone https://github.com/tux2603/mc-ctf.git
                ;;
            "Tag")
                git clone https://github.com/tux2603/mc-freezetag.git
                ;;
            "Done")
                break
                ;;
        esac
    done
    popd

    echo -n "View distance (default 8): "
    read viewDistance

    echo -n "Spawn protection radius (default 16): "
    read spawnProtection

    echo -n "Op permission level (default 2): "
    read opPermissionLevel

    echo -n "Function permission level (default 2): "
    read functionPermissionLevel

    echo -n "Nether enabled (default true): "
    read allowNether

    echo -n "Enable whitelist (default false): "
    read whitelist

    echo -n "Spawn NPCs (default true): "
    read spawnNPCS 

    echo -n "Spawn animals (default true): "
    read spawnAnimals

    echo -n "Spawn monsters (default true): "
    read spawnMonsters

    echo -n "Message of the day (default shameless plug): "
    read motd
    

fi

viewDistance=${viewDistance:-"8"}
spawnProtection=${spawnProtection:-"16"}
opPermissionLevel=${opPermissionLevel:-"2"}
functionPermissionLevel=${functionPermissionLevel:-"2"}
allowNether=${allowNether:-"true"}
whitelist=${whitelist:-"false"}
spawnNPCS=${spawnNPCS:-"true"}
spawnAnimals=${spawnAnimals:-"true"}
spawnMonsters=${spawnMonsters:-"true"}
motd=${motd:-"Fork me on github! https://github.comtux2603/"}

echo "Configuring server..."

cat << EOF >server.properties
#Minecraft server properties
broadcast-rcon-to-ops=true
view-distance=$viewDistance
max-build-height=256
server-ip=
rcon.port=25575
level-seed=
allow-nether=$allowNether
gamemode=survival
enable-command-block=true
server-port=$port
enable-rcon=false
enable-query=false
op-permission-level=$opPermissionLevel
prevent-proxy-connections=false
generator-settings=
resource-pack=
player-idle-timeout=0
level-name=world
rcon.password=
motd=$motd
query.port=25565
force-gamemode=false
hardcore=false
white-list=$whitelist
broadcast-console-to-ops=true
pvp=true
spawn-npcs=$spawnNPCS
spawn-animals=$spawnAnimals
generate-structures=true
snooper-enabled=true
difficulty=normal
function-permission-level=$functionPermissionLevel
network-compression-threshold=256
level-type=default
max-tick-time=60000
spawn-monsters=$spawnMonsters
enforce-whitelist=false
max-players=$players
use-native-transport=true
spawn-protection=$spawnProtection
resource-pack-sha1=
online-mode=true
allow-flight=true
max-world-size=29999984
EOF

cat << EOF >startServer.sh
#!/bin/bash
java -Xmx${maxRam}G -Xms${minRam}G -jar server.jar nogui
EOF

chmod 0755 startServer.sh

echo "Done. Start the server by running './startServer.sh'"
