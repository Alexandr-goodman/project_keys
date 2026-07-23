# Ввод размера массива
N = int(input("Введите количество элементов массива N: "))

# Создаем пустой массив
A = []

# Заполняем массив с клавиатуры
print("Введите", N, "чисел через пробел:")
numbers = input().split()

# Преобразуем введенные строки в числа и добавляем в массив
for i in range(N):
    A.append(int(numbers[i]))

# Находим индекс максимального элемента
max_idx = 0
for i in range(1, N):
    if A[i] > A[max_idx]:
        max_idx = i

# Находим индекс минимального элемента
min_idx = 0
for i in range(1, N):
    if A[i] < A[min_idx]:
        min_idx = i

# Определяем левую и правую границу
if max_idx < min_idx:
    start = max_idx
    end = min_idx
else:
    start = min_idx
    end = max_idx

# Считаем сумму отрицательных элементов между ними
sum_neg = 0
# ИСПРАВЛЕНИЕ: нужно исключить сами максимум и минимум
for i in range(start, end + 1):
    if i != max_idx and i != min_idx:  # Исключаем максимум и минимум
        if A[i] < 0:
            sum_neg += A[i]

# Выводим результат
print("Сумма отрицательных элементов между максимумом и минимумом =", sum_neg)