@echo off
chcp 65001 >nul
:: Устанавливаем UTF-8 для вывода сообщений

:: Проверка пути скрипта
set scriptPath=%~dp0
set "path_no_spaces=%scriptPath: =%"
if not "%scriptPath%"=="%path_no_spaces%" (
    echo Путь содержит пробелы. Переместите скрипт в директорию без пробелов.
    pause
    exit /b
)

:: Указываем путь к папке с бинарными файлами
set FILES=%~dp0files\

:: Проверка наличия необходимых файлов
for %%F in (
    "%FILES%rknsuck.exe"
    "%~dp0domains.txt"
    "%FILES%quic_initial_www_google_com.bin"
    "%FILES%tls_clienthello_www_google_com.bin"
) do (
    if not exist %%F (
        echo Не найден файл: %%F
        pause
        exit /b
    )
)

:: Запуск rknsuck.exe с минимизацией окна
start "Запуск DPI обхода" /min "%FILES%rknsuck.exe" ^
--wf-tcp=80,443 --wf-udp=443,50000-65535 ^
--filter-udp=443 --hostlist="%~dp0domains.txt" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic="%FILES%quic_initial_www_google_com.bin" --new ^
--filter-udp=50000-65535 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic="%FILES%quic_initial_www_google_com.bin" --new ^
--filter-tcp=80 --hostlist="%~dp0domains.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --hostlist="%~dp0domains.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%FILES%tls_clienthello_www_google_com.bin"

:: Уведомление о запуске
echo RKN Suck запущен. Проверяйте работу. Закройте окно, если больше не нужно.
pause
