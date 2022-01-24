Red []

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