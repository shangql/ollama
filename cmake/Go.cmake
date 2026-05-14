# Go.cmake — Go 语言构建辅助模块
# 提供 Go 程序编译、安装、测试、清理等功能

include_guard(GLOBAL)

# ============================================================
# 查找 Go 编译器
# ============================================================
find_program(GO_EXECUTABLE go REQUIRED)

if(NOT GO_EXECUTABLE)
    message(FATAL_ERROR "Go 编译器未找到，请安装 Go 1.24+")
endif()

# ============================================================
# 获取并验证 Go 版本（要求 >= 1.24）
# ============================================================
execute_process(
    COMMAND ${GO_EXECUTABLE} version
    OUTPUT_VARIABLE GO_VERSION_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE GO_VERSION_RESULT
)
if(NOT GO_VERSION_RESULT EQUAL 0)
    message(FATAL_ERROR "无法获取 Go 版本: ${GO_VERSION_OUTPUT}")
endif()

string(REGEX MATCH "go([0-9]+\\.[0-9]+(\\.[0-9]+)?)" GO_VERSION_MATCH "${GO_VERSION_OUTPUT}")
set(GO_VERSION "${CMAKE_MATCH_1}")

# 版本号拆分与比较（主版本.次版本）
string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" GO_VERSION_PARSED "${GO_VERSION}")
set(GO_VERSION_MAJOR "${CMAKE_MATCH_1}")
set(GO_VERSION_MINOR "${CMAKE_MATCH_2}")

if(GO_VERSION_MAJOR LESS 1 OR (GO_VERSION_MAJOR EQUAL 1 AND GO_VERSION_MINOR LESS 24))
    message(FATAL_ERROR "Go 版本 ${GO_VERSION} 过低，需要 Go 1.24+")
endif()

message(STATUS "Go 版本: ${GO_VERSION} (${GO_EXECUTABLE})")

# ============================================================
# 获取 Go 环境信息
# ============================================================
execute_process(
    COMMAND ${GO_EXECUTABLE} env GOMODCACHE
    OUTPUT_VARIABLE GO_MODCACHE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${GO_EXECUTABLE} env GOPATH
    OUTPUT_VARIABLE GO_GOPATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${GO_EXECUTABLE} env GOOS
    OUTPUT_VARIABLE GO_HOST_OS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${GO_EXECUTABLE} env GOARCH
    OUTPUT_VARIABLE GO_HOST_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${GO_EXECUTABLE} env GOROOT
    OUTPUT_VARIABLE GO_GOROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "Go 模块缓存: ${GO_MODCACHE}")
message(STATUS "Go 目标平台: ${GO_HOST_OS}/${GO_HOST_ARCH}")
message(STATUS "Go 安装目录: ${GO_GOROOT}")

# ============================================================
# 检测项目根目录是否包含 go.mod
# ============================================================
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/go.mod")
    message(FATAL_ERROR "未找到 go.mod 文件，请确保在 Go 项目根目录运行 CMake")
endif()

# ============================================================
# 验证 OLLAMA_BUILD_DIR 变量已定义
# ============================================================
if(NOT DEFINED OLLAMA_BUILD_DIR)
    message(FATAL_ERROR "OLLAMA_BUILD_DIR 变量未定义，请先包含主 CMakeLists.txt")
endif()

# ============================================================
# 定义 Go 构建目标
# 用法: ollama_add_go_target(
#     TARGET <名称>
#     PACKAGE <Go 包路径>
#     OUTPUT <输出二进制名>
#     [GOOS <目标操作系统>]
#     [GOARCH <目标架构>]
#     [CGO_ENABLED <0|1>]
#     [LDFLAGS <链接器标志>]
#     [TAGS <构建标签>]
#     [DEPENDS <依赖目标...>]
# )
# ============================================================
function(ollama_add_go_target)
    set(options "")
    set(oneValueArgs TARGET PACKAGE OUTPUT GOOS GOARCH CGO_ENABLED LDFLAGS TAGS CGO_CFLAGS CGO_CXXFLAGS CGO_LDFLAGS)
    set(multiValueArgs DEPENDS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # 验证必需参数
    if(NOT ARG_TARGET)
        message(FATAL_ERROR "ollama_add_go_target: 必须指定 TARGET")
    endif()
    if(NOT ARG_PACKAGE)
        message(FATAL_ERROR "ollama_add_go_target: 必须指定 PACKAGE")
    endif()
    if(NOT ARG_OUTPUT)
        set(ARG_OUTPUT "${ARG_TARGET}")
    endif()

    # 设置输出路径
    set(output_path "${OLLAMA_BUILD_DIR}/${ARG_OUTPUT}")

    # 构建 go build 参数
    set(go_build_args build)

    # 输出路径
    list(APPEND go_build_args -o "${output_path}")

    # 链接器标志
    if(ARG_LDFLAGS)
        list(APPEND go_build_args -ldflags "${ARG_LDFLAGS}")
    endif()

    # 构建标签
    if(ARG_TAGS)
        list(APPEND go_build_args -tags "${ARG_TAGS}")
    endif()

    # 目标包
    list(APPEND go_build_args "${ARG_PACKAGE}")

    # 设置环境变量
    set(go_env "")
    if(ARG_GOOS)
        list(APPEND go_env "GOOS=${ARG_GOOS}")
    endif()
    if(ARG_GOARCH)
        list(APPEND go_env "GOARCH=${ARG_GOARCH}")
    endif()
    # CGO 设置（交叉编译时默认关闭 CGO）
    if(DEFINED ARG_CGO_ENABLED)
        list(APPEND go_env "CGO_ENABLED=${ARG_CGO_ENABLED}")
    elseif(ARG_GOOS AND (NOT ARG_GOOS STREQUAL GO_HOST_OS))
        # 交叉编译时默认禁用 CGO
        list(APPEND go_env "CGO_ENABLED=0")
        message(STATUS "Go 目标 ${ARG_TARGET}: 交叉编译检测，自动禁用 CGO")
    endif()

    # CGO 编译/链接标志
    if(DEFINED ARG_CGO_CFLAGS)
        list(APPEND go_env "CGO_CFLAGS=${ARG_CGO_CFLAGS}")
    endif()
    if(DEFINED ARG_CGO_CXXFLAGS)
        list(APPEND go_env "CGO_CXXFLAGS=${ARG_CGO_CXXFLAGS}")
    endif()
    if(DEFINED ARG_CGO_LDFLAGS)
        list(APPEND go_env "CGO_LDFLAGS=${ARG_CGO_LDFLAGS}")
    endif()

    # 创建自定义目标（ALL 使其在默认构建时自动编译）
    add_custom_target(${ARG_TARGET} ALL
        COMMAND ${CMAKE_COMMAND} -E env ${go_env}
            ${GO_EXECUTABLE} ${go_build_args}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "正在构建 Go 目标: ${ARG_TARGET} (${ARG_PACKAGE})"
        VERBATIM
    )

    # 添加依赖
    if(ARG_DEPENDS)
        add_dependencies(${ARG_TARGET} ${ARG_DEPENDS})
    endif()

    # 安装规则
    install(PROGRAMS "${output_path}"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        COMPONENT Go
    )

    message(STATUS "Go 目标已配置: ${ARG_TARGET} -> ${output_path}")
endfunction()

# ============================================================
# 定义 Go 测试目标
# 用法: ollama_add_go_test(
#     TARGET <名称>
#     PACKAGE <Go 包路径>
#     [ARGS <测试参数...>]
# )
# ============================================================
function(ollama_add_go_test)
    set(options "")
    set(oneValueArgs TARGET PACKAGE)
    set(multiValueArgs ARGS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "ollama_add_go_test: 必须指定 TARGET")
    endif()
    if(NOT ARG_PACKAGE)
        message(FATAL_ERROR "ollama_add_go_test: 必须指定 PACKAGE")
    endif()

    set(go_test_args test)
    if(ARG_ARGS)
        list(APPEND go_test_args ${ARG_ARGS})
    endif()
    list(APPEND go_test_args "${ARG_PACKAGE}")

    add_custom_target(${ARG_TARGET}
        COMMAND ${GO_EXECUTABLE} ${go_test_args}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "正在运行 Go 测试: ${ARG_TARGET} (${ARG_PACKAGE})"
        VERBATIM
    )
endfunction()

# ============================================================
# 定义 Go 工具安装目标
# 用法: ollama_install_go_tool(
#     TARGET <名称>
#     PACKAGE <工具包路径>
# )
# ============================================================
function(ollama_install_go_tool)
    set(options "")
    set(oneValueArgs TARGET PACKAGE)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "ollama_install_go_tool: 必须指定 TARGET")
    endif()
    if(NOT ARG_PACKAGE)
        message(FATAL_ERROR "ollama_install_go_tool: 必须指定 PACKAGE")
    endif()

    add_custom_target(${ARG_TARGET}
        COMMAND ${GO_EXECUTABLE} install "${ARG_PACKAGE}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "正在安装 Go 工具: ${ARG_PACKAGE}"
        VERBATIM
    )
endfunction()

# ============================================================
# 下载 Go 模块依赖
# 用法: ollama_go_mod_download()
# ============================================================
function(ollama_go_mod_download)
    add_custom_target(go-mod-download
        COMMAND ${GO_EXECUTABLE} mod download
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "正在下载 Go 模块依赖..."
        VERBATIM
    )
endfunction()

# ============================================================
# 整理 Go 模块
# 用法: ollama_go_mod_tidy()
# ============================================================
function(ollama_go_mod_tidy)
    add_custom_target(go-mod-tidy
        COMMAND ${GO_EXECUTABLE} mod tidy
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "正在整理 Go 模块..."
        VERBATIM
    )
endfunction()

# ============================================================
# 生成 Go 代码（go generate）
# 用法: ollama_go_generate([PATTERN <模式>])
# ============================================================
function(ollama_go_generate)
    set(options "")
    set(oneValueArgs PATTERN)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "" ${ARGN})

    set(generate_pattern "./...")
    if(ARG_PATTERN)
        set(generate_pattern "${ARG_PATTERN}")
    endif()

    add_custom_target(go-generate
        COMMAND ${GO_EXECUTABLE} generate "${generate_pattern}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "正在执行 Go 代码生成..."
        VERBATIM
    )
endfunction()

# ============================================================
# 清理 Go 构建产物
# 用法: ollama_go_clean([EXTRA_PATHS <额外清理路径...>])
# ============================================================
function(ollama_go_clean)
    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs EXTRA_PATHS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(clean_paths "${OLLAMA_BUILD_DIR}")
    if(ARG_EXTRA_PATHS)
        list(APPEND clean_paths ${ARG_EXTRA_PATHS})
    endif()

    add_custom_target(go-clean
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${OLLAMA_BUILD_DIR}"
        COMMAND ${GO_EXECUTABLE} clean -cache -testcache
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "正在清理 Go 构建产物..."
        VERBATIM
    )

    message(STATUS "Go 清理目标已配置: go-clean")
endfunction()
