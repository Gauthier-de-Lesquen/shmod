#!/bin/bash

# ----------------- USAGE ERRORS -----------------
if [ $# -lt 1 ]; then
	echo -e "\033[31mError:\033[0m too less arguments for shmod"
	echo -e "usage: shmod \033[31m<file/dir/link>\033[0m [-option]"
	echo "type \"shmod -h\" to get help"
	exit 2
elif [ $# -gt 2 ]; then
	echo -e "\033[31mError:\033[0m too much arguments for shmod"
    echo "usage: shmod <file/dir/link> [-arg]"
    echo "type \"shmod -h\" to get help"
    exit 2
fi

if [ ! -e "$1" ] && [[ "$1" != "-h" ]]; then
    echo "-bash: shmod: $1: No such file or directory"
  	exit 2
fi

# ----------------- HELP -----------------

if [[ "$1" == "-h" ]]; then
	echo "SHMOD USAGE"
	echo -e "syntax: \`\033[34mshmod \033[32m<file/dir/link> \033[35m[-option]\033[0m'"
	echo -e "* the first argument is \033[31mmandatory\033[0m"
	echo -e "* it must be (excepting with \`shmod -h') the \033[32melement\033[0m whose permissions are shown"
	echo "* this element can be: "
	echo -e "  - a file\n  - a directory\n  - a symbolic link\n  - a character device\n  - a block device\n  - a socket\n  - a named pipe"
	echo -e "\n* the second argument is \033[31moptional\033[0m"
	echo -e "* it must be one of these \033[35moptions\033[0m"
	echo "  -d : to display details about permissions shown"
	echo -e "  -s : to display the permissions to their symbolic shape (e.g. -\033[34mrwx\033[32mr--\033[33mr--\033[0m)"
	echo -e "  -O : to display the permissions to their octal notation (e.g.  \033[34m7  \033[32m4  \033[33m4  \033[0m)"
	echo "  -T: to display the item type (file, directory, symbolic link...)"
	echo "* -s and -O can be cumulated with : "
	echo "  -t to see the type in tis symbolic notation (-/d/l/c/b/s/p)"
	echo "  -u to see only the user permissions"
	echo "  -g to see only the group permissions"
	echo "  -o to see only the others' permissions"
	echo -e "\nexamples:"
	echo "* shmod <file> -stugo diplays the same thing that shmod <file> -s"
	echo -e "* shmod <file> -sTtuO displays :\n  - the octal permissions of the user\n  - the symbolic notation of the permission with the type (-) and the user permissions (e.g. rwx)\n  - the item's type (file)"
	exit 0
fi

# ================= PROGRAM BODY =================

symbolic=$(stat -c "%A" $1) # get the symbolic permission (e.g.: -rwxr--r--)

# ----------------- DETERMINE TYPE  -----------------
type="${symbolic:0:1}"
filetype=""
case $type in
    "-") filetype="file" ;;
    "d") filetype="directory" ;;
    "l") filetype="symbolic link" ;;
    "c") filetype="character device" ;;
    "b") filetype="block device" ;;
    "s") filetype="socket" ;;
    "p") filetype="named pipe" ;;
    *) echo "shmod: error: invalid permission format"
       exit 1 ;;
esac

#  ----------------- CHECK FOR THE OPTIONS  -----------------

if [[ "$2" == *-* ]] && [[ "$2" != "-d" ]]; then
    if [[ "$2" == *O* ]]; then
	    octal=$(stat -c "%a" $1)

        octalshown=""
        if [[ "$2" == *u* ]]; then
            octalshown="${octal:0:1}"
        fi

        if [[ "$2" == *g* ]]; then
            octalshown="${octalshown}${octal:1:1}"
        fi

        if [[ "$2" == *o* ]]; then
            octalshown="${octalshown}${octal:2:1}"
        fi

        if [[ "$2" != *u* ]] && [[ "$2" != *g* ]] && [[ "$2" != *o* ]]; then
            octalshown="$octal"
        fi

        echo "$octalshown"
    fi

    if [[ "$2" == *s* ]]; then

        symbolicshown=""
        if [[ "$2" == *t* ]]; then
            symbolicshown="\033[31m$type"
        fi

        if [[ "$2" == *u* ]]; then
            symbolicshown="${symbolicshown}\033[34m${symbolic:1:3}"
        fi

        if [[ "$2" == *g* ]]; then
            symbolicshown="${symbolicshown}\033[32m${symbolic:4:3}"
        fi

        if [[ "$2" == *o* ]]; then
            symbolicshown="${symbolicshown}\033[33m${symbolic:7:3}"
        fi

        if [[ "$2" != *u* ]] && [[ "$2" != *g* ]] && [[ "$2" != *o* ]] && [[ "$2" != *t* ]]; then
            symbolicshown="\033[31m$type\033[34m${symbolic:1:3}\033[32m${symbolic:4:3}\033[33m${symbolic:7:3}"
        fi

        echo -e "$symbolicshown\033[0m"
    
    elif [[ "$2" == *t* ]]; then
        symbolic=$(stat -c "%A" $1)
        echo "${symbolic:0:1}"
    fi

    if [[ "$2" == *T* ]]; then
        echo "$filetype"
    fi

    exit 0
fi

# ----------------- TRANSLATE THE PERMISSIONS TO A BETTER FORMAT  -----------------
usrperms=()
usrpermsstring="${symbolic:1:3}"
if [[ "${usrpermsstring:0:1}" == "r" ]]; then
	if [[ "$2" == "-d" ]]; then
		if [[ "$type" == "d" ]]; then
			usrperms+=("read \033[90m-> the owner can see what is in the directory using commands as ls\033[0m")
		else
			usrperms+=("read \033[90m-> the owner can read the content of the $filetype\033[0m")
		fi
	else
		if [[ "$type" == "d" ]]; then
			usrperms+=("read (ls)")
		else
			usrperms+=("read")
		fi
	fi
elif [[ "${usrpermsstring:0:1}" != "-" ]]; then
	echo "error: invalid permission format"
	exit 1
fi

if [[ "${usrpermsstring:1:1}" == "w" ]]; then
	if [[ "$2" == "-d" ]]; then
		usrperms+=("write \033[90m-> the owner can write in the $filetype\033[0m")
	else
		usrperms+=("write")
	fi
elif [[ "${usrpermsstring:1:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

if [[ "${usrpermsstring:2:1}" == "x" ]]; then
    if [[ "$2" == "-d" ]]; then
		if [[ "$type" == "d" ]]; then
			usrperms+=("execute \033[90m-> the owner can cross or be in the directory, using commands as cd\033[0m")
		else
			usrperms+=("execute \033[90m-> the owner can execute the $filetype\033[0m")
		fi
	else
		if [[ "$type" == "d" ]]; then
			usrperms+=("execute (cd)")
		else
			usrperms+=("execute")
		fi
	fi
elif [[ "${usrpermsstring:2:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

gpperms=()
gppermsstring="${symbolic:4:3}"
if [[ "${gppermsstring:0:1}" == "r" ]]; then
    if [[ "$2" == "-d" ]]; then
		if [[ "$type" == "d" ]]; then
			gpperms+=("read \033[90m-> a member of the group can see what is in the directory using commands as ls\033[0m")
		else
			gpperms+=("read \033[90m-> a member of the group can read the content of the $filetype\033[0m")
		fi
	else
		if [[ "$type" == "d" ]]; then
			gpperms+=("read (ls)")
		else
			gpperms+=("read")
		fi
	fi
elif [[ "${gppermsstring:0:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

if [[ "${gppermsstring:1:1}" == "w" ]]; then
    if [[ "$2" == "-d" ]]; then
		gpperms+=("write \033[90m-> a member of the group can write in the $filetype\033[0m")
	else
		gpperms+=("write")
	fi
elif [[ "${gppermsstring:1:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

if [[ "${gppermsstring:2:1}" == "x" ]]; then
    if [[ "$2" == "-d" ]]; then
		if [[ "$type" == "d" ]]; then
			gpperms+=("execute \033[90m-> a member of the group can cross or be in the directory, using commands as cd\033[0m")
		else
			gpperms+=("execute \033[90m-> a member of the group can execute the $filetype\033[0m")
		fi
	else
		if [[ "$type" == "d" ]]; then
			gpperms+=("execute (cd)")
		else
			gpperms+=("execute")
		fi
	fi
elif [[ "${gppermsstring:2:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

othperms=()
othpermsstring="${symbolic:7:3}"
if [[ "${othpermsstring:0:1}" == "r" ]]; then
	if [[ "$2" == "-d" ]]; then
		if [[ "$type" == "d" ]]; then
			othperms+=("read \033[90m-> the other users can see what is in the directory using commands as ls\033[0m")
		else
			othperms+=("read \033[90m-> the other users can read the content of the $filetype")
		fi
	else
		if [[ "$type" == "d" ]]; then
			othperms+=("read (ls)")
		else
            othperms+=("read")
		fi
	fi
elif [[ "${othpermsstring:0:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

if [[ "${othpermsstring:1:1}" == "w" ]]; then
	if [[ "$2" == "-d" ]]; then
		othperms+=("write \033[90m-> the other users can write in the $filetype\033[0m")
	else
		othperms+=("write")
	fi
elif [[ "${othpermsstring:1:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

if [[ "${othpermsstring:2:1}" == "x" ]]; then
    if [[ "$2" == "-d" ]]; then
		if [[ "$type" == "d" ]]; then
			othperms+=("execute \033[90m-> the other users can cross or be in the directory, using commands as cd\033[0m")
		else
			othperms+=("execute \033[90m-> the other users can execute the $filetype")
		fi
	else
		if [[ "$type" == "d" ]]; then
			othperms+=("execute (cd)")
		else
			othperms+=("execute")
		fi
	fi
elif [[ "${othpermsstring:2:1}" != "-" ]]; then
    echo "error: invalid permission format"
    exit 1
fi

echo -e "\033[35m${filetype^^} PERMISSIONS:"
echo -e "\033[31mitem type:\033[0m $filetype"
echo -e "\n\033[34muser permissions:\033[0m"
if [[ "$2" == "-d" ]]; then
	echo -e "\033[90m=> only the author of the $filetype has this permissions:\033[0m"
fi
for perm in "${usrperms[@]}"; do
	echo -e "- $perm"
done

echo -e "\n\033[32mgroup permissions:\033[0m"
if [[ "$2" == "-d" ]]; then
	echo -e "\033[90m=> only the members of the group have this permissions:\033[0m"
fi
for perm in "${gpperms[@]}"; do
	echo -e "- $perm"
done

echo -e "\n\033[33mothers' permissions:\033[0m"
if [[ "$2" == "-d" ]]; then
	echo -e "\033[90m=> all the other users of the device have this permissions:\033[0m"
fi
for perm in "${othperms[@]}"; do
	echo -e "- $perm"
done
if [[ "$2" != "-d" ]]; then
	echo -e "\n\033[90m=> type shmod $1 -d to see more detailed informations\033[0m"
fi
exit 0
