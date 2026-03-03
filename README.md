# shmod
> this is a Linux command that permits to see the permissions of a file, directory, symbolic link, etc. more easily to understand than ```-rwxr--r--```

## specification
### syntax:
```
shmod <file/dir/link...> [-option]
```
### explanations
* the first argument is **mandatory**
* the first argument can be -h to get help, otherwise it is the element whose permissions are shown
* it can be:
  - a file
  - a directory
  - a symbolic link
  - a character device
  - a block device
  - a name pipe

* the second argument is optional and can be one or more (cumulated in one argument) option.
* it can be one of these options: \
  ```-s``` to see the permissions with their symbolic notation (as -rwxr--r--) \
  ```-O``` to see the permissions with their octal notation (as 744) \
  ```-t``` to see the item type with thier symbolic notation (-/d/l/c/b/s/p) \
  ```-T``` to see the item type in english (file/directory/symbolic link...) \
  ```-u``` to see only the user permissions \
  ```-g``` to see only the group permissions \
  ```-o``` to see only the others' permissions \
  ```-d``` to see the permissions with details about what they really mean (it c'ant be cumulated with the others)

### examples:
* ```shmod <file> -su``` displays (for example):
```
rwx
```
* ```shmod <file> -sO``` displays (for example):
```
744
-rwxr--r--
```
* ```shmod <file> -sOugT``` displays:
```
74
-rwxr--
file
```
