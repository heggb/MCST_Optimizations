# MCST_Optimizations

Этот репозиторий содержит демонстрации и примеры реализации оптимизаций компилятора на основе LLVM. Он подходит для учебных и исследовательских целей, связанных с анализом промежуточного представления (IR) и применением различных трансформаций к коду на C.

## 📁 Состав проекта

- `src/*.c` — Примеры программ на C, демонстрирующих работу определённых оптимизаций:
  - `const_propagation.c` — распространение констант (Constant Propagation)
  - `dce.c` — устранение мёртвого кода (Dead Code Elimination)
  - `gvn.c` — глобальная нумерация выражений (Global Value Numbering)
  - `indvars.c` — оптимизация переменных цикла (Induction Variables)
  - `inline.c` — инлайнинг функций (Function Inlining)
  - `licm.c` — поднятие инвариантов цикла (Loop Invariant Code Motion)
  - `loop_peeling.c` — расщепление циклов (Loop Peeling)
  - `loop_unroll.c` — разворачивание циклов (Loop Unrolling)
  - `uce.c` — устранение недостижимого кода (Unreachable Code Elimination)

- `llvm_opt_demo.sh` — bash-скрипт, демонстрирующий применение LLVM-оптимизаций к одному из примеров. Позволяет сравнить промежуточное представление (IR) до и после оптимизации.

## ⚙️ Требования

Для использования проекта необходимо установить:

- [`clang`](https://clang.llvm.org/) — компилятор Clang
- [`opt`](https://llvm.org/docs/CommandGuide/opt.html) — инструмент оптимизации из набора LLVM
- Bash — для запуска скриптов

### Установка (Ubuntu)

```bash
sudo apt update
sudo apt install llvm clang
```

## 🚀 Быстрый старт

1. **Склонируйте репозиторий или распакуйте архив:**

```bash
git clone <ссылка_на_репозиторий>
cd MCST_Optimizations
```

2. **Выберите интересующий пример, например `licm.c`. Скомпилируйте его в LLVM IR:**

```bash
clang -S -emit-llvm src/licm.c -o licm.ll
```

3. **Примените к нему одну или несколько оптимизаций, например LICM (Loop Invariant Code Motion):**

```bash
opt -mem2reg -licm licm.ll -o - | llvm-dis > licm_optimized.ll
```

4. **Сравните результат до и после оптимизации:**

```bash
diff licm.ll licm_optimized.ll
```

5. **Или запустите демонстрационный скрипт, который автоматически покажет IR до и после оптимизаций:**

```bash
chmod +x llvm_opt_demo.sh
./llvm_opt_demo.sh
```
