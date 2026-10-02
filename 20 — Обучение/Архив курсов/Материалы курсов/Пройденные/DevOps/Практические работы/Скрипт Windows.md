Напишите скрипт в Windows, который будет искать среди установленных программ совпадение по имени и выводить в консоль приветственное сообщение и количество совпадений. При выполнении задания опирайтесь на вводные данные:

- Скрипт должен получать из консоли параметры типа `string: \\`:
    - `programm_name` для поиска совпадений,
    - `hellow_message` для вывода приветственного сообщения.
- В скрипте должно быть две функции:
    - `get_programms`, которая будет запускаться первой и получать список программ:
        - результат поиска программ вносите в переменную `$value`;
        - используйте стандартный командлет для поиска свойств элементов — в этом поможет таблица первого урока темы;
        - поиск программ производите в реестре `HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*`;
        - выбирайте только поле `DisplayName`;
        - убедитесь, что после поиска вызывается функция `make_message` и в неё передаётся объект `$value`.
    - `make_message`, выводящая в консоль сложенные строки в виде сообщения:
        - эта функция принимает объект;
        - создаёт переменную `$message` с приветственным сообщением;
        - добавляет на новую строку в переменную `$message` значение `Elements in Object - кол-во элементов в объекте`;
        - возвращает переменную `$message` в консоль.

```
Param (
    [string]$programm_name,
    [string]$hellow_message
)

function make_message([Object]$value) {
    $message = "$hellow_message`n"
    $message += "Elements in Object - " + $value.count + "`n"
    return $message
}

function get_programms {
    $value = Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* |
             Where-Object {$_.DisplayName -like "*$programm_name*"} |
             Select-Object DisplayName |
             ForEach-Object {$_.DisplayName}
    make_message $value
}

get_programms
```

![[Pasted image 20260408182821.png]]

