#!/bin/bash

# Конфигурация
SRC_DIR="src"
OUTPUT_DIR="output"
CLANG="clang-18"
OPT="opt-18"

# Цвета для вывода
NC='\033[0m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'

# Функция для вывода команд
show_command() {
    echo -e "${BLUE}Команда:${NC}"
    echo -e "${BLUE}$1${NC}"
}

# Функция очистки каталога output
clean_output() {
    echo -e "\n${GREEN}Удаление каталога output${NC}"
    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"
        echo "Каталог output удален"
    else
        echo "Каталог output не существует"
    fi
}

# Генерация IR
generate_ir() {
    local cmd="$CLANG -S -emit-llvm  -Xclang -disable-O0-optnone -o $2 $1"
    show_command "$cmd"
    if ! $cmd; then
        echo "Ошибка генерации IR!" >&2
        exit 1
    fi
}

# Применение оптимизации
apply_optimization() {
    local cmd
    case "$1" in
        "const_propagation")
            cmd="$OPT -S --passes=sccp,instcombine -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "inline")
            local cmd="$CLANG -S -emit-llvm -O0 -mllvm -disable-llvm-optzns -fno-discard-value-names -o $2 $1"
            cmd="$OPT -S --passes=always-inline -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "dce")
            cmd="$OPT -S --passes=mem2reg -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "licm")
            cmd="$OPT -S --passes=licm -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "uce")
            #local cmd="$CLANG -S -emit-llvm  -O0 -o $2 $1"
            cmd="$OPT -S --passes=mem2reg,dce,simplifycfg -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "loop_unroll")
            cmd="$OPT -S --passes=mem2reg,loop-simplify,loop-unroll -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "gvn")
            cmd="$OPT -S --passes=gvn -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "indvars")
            cmd="$OPT -S --passes=mem2reg,loop-simplify,indvars -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        "loop_peeling")
            local cmd="$CLANG -S -emit-llvm -O0 -mllvm -disable-loop-vectorization -disable-llvm-optzns -fno-discard-value-names -o $2 $1"
            cmd="$OPT -S --passes="mem2reg,loop-simplify,loop-unroll" \
            -unroll-peel-count=1 \
            -unroll-threshold=9999 \
            -o $3 $2"
            show_command "$cmd"
            $cmd || exit 1
            ;;
        *)
            echo "Неизвестная оптимизация: $1" >&2
            exit 1
            ;;
    esac
}

# Основная логика
if [ $# -eq 0 ]; then
    echo "Доступные оптимизации:"
    echo "  clean             - Очистить каталог output"
    echo "  const_propagation - Продвижение констант"
    echo "  inline            - Подстановка функций"
    echo "  dce               - Удаление мёртвого кода"
    echo "  licm              - Вынос инвариантов цикла"
    echo "  uce               - Удаление недостижимого кода"
    echo "  loop_unroll       - Разворот цикла"
    echo "  gvn               - Глобальная нумерация значений"
    echo "  indvars           - Индуктивные переменные"
    echo "  loop_peeling      - Открутка итераций"
    echo ""
    echo "Использование: $0 <оптимизация>"
    exit 1
fi

# Обработка команды clean
if [ "$1" = "clean" ]; then
    clean_output
    exit 0
fi

selected_opt="$1"
c_file="$SRC_DIR/${selected_opt}.c"
ir_before="$OUTPUT_DIR/${selected_opt}_before.ll"
ir_after="$OUTPUT_DIR/${selected_opt}_after.ll"

# Проверка файла
if [ ! -f "$c_file" ]; then
    echo "Файл $c_file не найден!" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Вывод исходного кода
echo -e "\n${GREEN}Исходный C-код для оптимизации:${NC}"
echo -e "${YELLOW}"
cat "$c_file"
echo -e "${NC}"

# Генерация IR
echo -e "\n${GREEN}Этап 1: Генерация LLVM IR${NC}"
generate_ir "$c_file" "$ir_before"

# Вывод IR до оптимизации
echo -e "\n${GREEN}LLVM IR до оптимизации:${NC}"
cat "$ir_before"

# Применение оптимизации
echo -e "\n${GREEN}Этап 2: Применение оптимизации ${selected_opt}${NC}"
apply_optimization "$selected_opt" "$ir_before" "$ir_after"

# Вывод IR после оптимизации
echo -e "\n${GREEN}LLVM IR после оптимизации:${NC}"
cat "$ir_after"
