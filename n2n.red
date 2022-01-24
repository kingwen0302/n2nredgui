Red [
    Needs: 'view
]

;; 如果有配置文件的话, 从配置文件中加载, 否则默认数据
case [
    exists? %config.red [
        do read %config.red
    ]
    true [
        ;; 配置文件
        users: [
            ; 用户和分配的IP
            ["user1" "192.168.254.3" ]
            ["user2" "192.168.254.2" ]
        ]
        users_index_name: 1
        users_index_ip: 2
        
        servers: [
            ["default1" "example1.com:10800" "mynetwork1" "mypassword1"]
            ["default2" "example2.com:10800" "mynetwork2" "mypassword2"]
        ]

        servers_index_name: 1
        servers_index_supernode: 2
        servers_index_community: 3
        servers_index_encrypt_key: 4

        ping_ip: "192.168.254.1"

    ]
]

;; 转换list为map
users_map: make map! []
servers_map: make map! []

i: 1
user_names: []
while [ i <= (length? users) ] [
    put users_map i users/(i)
    append user_names users/(i)/(users_index_name)
    i: i + 1
]

i: 1
server_names: []
while [ i <= (length? servers) ] [
    put servers_map i servers/(i)
    append server_names servers/(i)/(servers_index_name)
    i: i + 1
]

select_id: 0

label_size: 100
field_size: 200
button_size: 150

edge_ver_name_list: ["v1 - 1.3.2" "v2 - 2.8" "v2s - 2.1" "v3 - 3.x"]
edge_ver_name_map: make map! [1 "v1" 2 "v2" 3 "v2s" 4 "v3"]
edge_version: ""

edge_v1_url: https://cdn.jsdelivr.net/gh/kingwen0302/n2nredgui/bin/edge_v1.exe.gz
edge_v2_url: https://cdn.jsdelivr.net/gh/kingwen0302/n2nredgui/bin/edge_v2.exe.gz
edge_v2s_url: https://cdn.jsdelivr.net/gh/kingwen0302/n2nredgui/bin/edge_v2s.exe.gz
edge_v3_url: https://cdn.jsdelivr.net/gh/kingwen0302/n2nredgui/bin/edge_v3.exe.gz
tap_url: https://cdn.jsdelivr.net/gh/kingwen0302/n2nredgui/bin/tap-windows-9.21.2.exe.gz

down_binary: func [file url] [
    if not exists? file [
        write/binary file (decompress read/binary url)
    ]
]

copy_binary: func [to_file from_file] [
    if not exists? to_file [
        write/binary to_file (read/binary from_file)
    ]
]

view [
    title "N2N启动程序"
    
    h5 font-color Red "！！！NOTE: 请以管理员身份运行！！！"
    return

    style separator: h5 ">>>>>>>>>>>>>>>>>>>" 
    separator
    return

    h5 font-color Blue "edge版本:" label_size
    drop-down "" data edge_ver_name_list field_size
    on-change [
        select_id: face/selected
        edge_version: edge_ver_name_map/(select_id)
    ]
    h5 font-color Red "要与supernode版本一致"
    return

    h5 font-color Blue "预置server: " label_size
    drop-down "" data server_names field_size
    on-change [
        select_id: face/selected

        f_supernode/text: servers_map/(select_id)/(servers_index_supernode)
        f_community/text: servers_map/(select_id)/(servers_index_community)
        f_encrypt_key/text: servers_map/(select_id)/(servers_index_encrypt_key)
    ]
    return

    h5 font-color Blue "预置账户:" label_size
    drop-down "" data user_names field_size
    on-change [
        select_id: face/selected
        f_ip/text: users_map/(select_id)/(users_index_ip)
    ] 
    return

    h5 font-color Blue "是否DEBUG:" label_size
    is_debug: check font-size 13 "否"
    on-change [
        either is_debug/data 
            [is_debug/text: "是"]
            [is_debug/text: "否"]
        
        print is_debug/data
    ]
    return

    separator
    return

    h5 "community:" label_size
    f_community: field "" field_size
    return

    h5 "encrypt_key:" label_size
    f_encrypt_key: field "" field_size
    return

    h5 "supernode:" label_size
    f_supernode: field "" field_size
    return

    h5 "ip:" label_size
    f_ip: field "" field_size
    return

    separator
    return

    button font-size 14 bold font-color Red "1. 下载/安装" button_size [
        down_binary %edge_v1.exe edge_v1_url
        down_binary %edge_v2.exe edge_v2_url
        down_binary %edge_v2s.exe edge_v2s_url
        down_binary %edge_v3.exe edge_v3_url
        down_binary %tap-windows-9.21.2.exe tap_url

        call "start tap-windows-9.21.2.exe"
        alert "下载完成，准备安装Tap-Windows！！！"
    ]
    button font-size 14 bold "2. 启动/重启N2N" button_size [
        case [
            select_id = 0 [alert "没有选择"]
            true [
                ;; 复制binary文件
                to_edge_binary: rejoin ["edge_" edge_version "_" f_ip/text ".exe" ]
                from_edge_binary: rejoin ["edge_" edge_version ".exe"]
                copy_binary (to-file to_edge_binary) (to-file from_edge_binary)

                ;; 生成启动脚本
                to_edge_bat: rejoin ["edge_" edge_version "_" f_ip/text ".bat"]
                write (to-file to_edge_bat) rejoin [
                    "@echo off" newline
                    "taskkill /F /IM " to_edge_binary newline
                    to_edge_binary " -a " f_ip/text 
                    " -c " f_community/text
                    " -k " f_encrypt_key/text 
                    " -l " f_supernode/text 
                    " -b" newline
                ]

                ; print is_debug/data
                either is_debug/data 
                [
                    ;; debug 启动
                    call rejoin ["start /min cmd /C " to_edge_bat ]
                ]
                [
                    ;; release 启动
                    call rejoin [
                        "cmd /C " to_edge_bat
                    ]
                    alert "启动完成，测试PING"
                ]
            ]

        ] 
    ]
    button font-size 14 bold "3. 测试(PING)" button_size [
        case [
            select_id = 0 [alert "没有选择"] 
            true [
                ; print rejoin ["start ping " ping_ip]
                print is_debug/data
                call rejoin ["start ping " ping_ip]
            ]
        ] 
    ]
    return

    separator
    return

    h5 font-color Red "1. 请用管理员身份运行；"
    return
    h5 font-color Red "2. 先下载，安装Tap-Windows，已安装的忽略；"
    return
    h5 font-color Red "3. 请不要关闭命令行，若连接不上，请关闭命令行窗口重试；"
    return
    h5 font-color Red "4. edge版本要和supernode版本一致。"
]