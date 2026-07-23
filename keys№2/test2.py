#Написать тестовую программу, которая демонстрирует работу методов базового и производного классов.
# =============================================
# БАЗОВЫЙ КЛАСС: Тур (Tour)
# =============================================
class Tour:
    """Обычный тур - базовый класс"""
    
    def __init__(self, tour_id, customer_name, country, duration_days, total_cost):
        """Конструктор. Здесь хранятся основные данные тура"""
        self.tour_id = tour_id
        self.customer_name = customer_name
        self.country = country
        self.duration_days = duration_days
        self.total_cost = total_cost
        print(f"Создан обычный тур для клиента {customer_name}")
    
    def display_info(self):
        """Вывод информации о туре"""
        print(f"\n{'='*40}")
        print(f"Информация о туре #{self.tour_id}")
        print(f"{'-'*40}")
        print(f"Клиент: {self.customer_name}")
        print(f"Страна: {self.country}")
        print(f"Длительность: {self.duration_days} дней")
        print(f"Стоимость: {self.total_cost:,.2f} руб.")
    
    def calculate_discount(self):
        """Скидка для обычного тура - 5%"""
        discount = self.total_cost * 0.05
        print(f"Скидка 5% составила: {discount:,.2f} руб.")
        return discount
    
    def check_duration(self):
        """Определяем тип тура по длительности"""
        if self.duration_days >= 10:
            return "Длительный тур (более 10 дней)"
        elif self.duration_days >= 5:
            return "Стандартный тур (5-10 дней)"
        else:
            return "Краткосрочный тур (менее 5 дней)"
    
    def get_final_price(self):
        """Получение итоговой цены со скидкой"""
        discount = self.calculate_discount()
        final_price = self.total_cost - discount
        print(f"Итоговая цена: {final_price:,.2f} руб.")
        return final_price


# =============================================
# Производный класс: VIP Тур (VipTour)
# Наследуется от базового класса Tour
# =============================================
class VipTour(Tour):
    """VIP-тур - расширенный вариант обычного тура"""
    
    def __init__(self, tour_id, customer_name, country, duration_days, total_cost,
                 personal_manager, has_transfer, hotel_class):
        """Конструктор производного класса"""
        # Вызов конструктора базового класса
        super().__init__(tour_id, customer_name, country, duration_days, total_cost)
        
        # Добавляем новые свойства для VIP
        self.personal_manager = personal_manager
        self.has_transfer = has_transfer
        self.hotel_class = hotel_class
        print(f"VIP-тур с менеджером {personal_manager}")
    
    def display_info(self):
        """Переопределяем метод вывода. Добавляем VIP-информацию (ПОЛИМОРФИЗМ)"""
        # Вызов метода базового класса
        super().display_info()
        
        # Добавляем VIP-информацию
        print(f"\n VIP-ДОПОЛНИТЕЛЬНАЯ ИНФОРМАЦИЯ")
        print(f"Персональный менеджер: {self.personal_manager}")
        print(f"Трансфер: {'Включён ✅' if self.has_transfer else 'Не включён ❌'}")
        print(f"Класс отеля: {self.hotel_class}")
        print(f"Статус: VIP-клиент ⭐")
    
    def calculate_discount(self):
        """VIP-скидка больше - 15% вместо 5%"""
        # Базовая скидка 5%
        base_discount = super().calculate_discount()
        
        # Дополнительная VIP-скидка 10%
        vip_bonus = self.total_cost * 0.10
        total_discount = base_discount + vip_bonus
        
        print(f"Дополнительный VIP-бонус 10%: {vip_bonus:,.2f} руб.")
        print(f"Итоговая скидка VIP:: {total_discount:,.2f} руб.")
        return total_discount
    
    def get_vip_status(self):
        """Новый метод, которого нет в базовом классе"""
        if self.total_cost > 200000:
            return "PLATINUM VIP 🌟"
        elif self.total_cost > 100000:
            return "GOLD VIP ✨"
        else:
            return "SILVER VIP 💎"
    
    def get_vip_service(self):
        """Возвращает список услуг для VIP-клиента"""
        services = []
        if self.has_transfer:
            services.append("Трансфер из аэропорта")
        services.append(f"Размещение в {self.hotel_class}")
        services.append(f"Личный менеджер: {self.personal_manager}")
        services.append("Приветственный подарок")
        return services

# ТЕСТИРОВАНИЕ 
def main():
    """Здесь проверяем работу всех методов"""
    
    print("="*50)
    print("ПРОВЕРКА РАБОТЫ КЛАССОВ")
    print("="*50)
    
    # 1. Тестируем базовый класс
    
    print("\n🔹 ОБЫЧНЫЙ ТУР:")
    print("-"*40)
    
    regular_tour = Tour(
        tour_id=1,
        customer_name="Иванов Иван",
        country="Турция",
        duration_days=7,
        total_cost=140000.00
    )
    
    # Вызов методов базового класса
    regular_tour.display_info()
    print(f"\nТип тура: {regular_tour.check_duration()}")
    regular_tour.get_final_price()
    
    
    # 2. СОЗДАНИЕ ОБЪЕКТА ПРОИЗВОДНОГО КЛАССА
  
    print("\n\n VIP-ТУР:")
    print("-"*40)
    
    vip_tour = VipTour(
        tour_id=5,
        customer_name="Николаев Дмитрий",
        country="Египет",
        duration_days=12,
        total_cost=175000.00,
        personal_manager="Анна Смирнова",
        has_transfer=True,
        hotel_class="5 звёзд, люкс"
    )
    
    # Вызов методов производного класса
    vip_tour.display_info()
    print(f"\nТип тура: {vip_tour.check_duration()}")
    print(f"VIP-статус: {vip_tour.get_vip_status()}")
    print(f"\nДополнительные услуги:")
    for service in vip_tour.get_vip_service():
        print(f"  {service}")
    vip_tour.get_final_price()
    
    
    # 3. ДЕМОНСТРАЦИЯ ПОЛИМОРФИЗМА
    
    print("\n\nДЕМОНСТРАЦИЯ ПОЛИМОРФИЗМА:")
    print("-"*40)
    
    # Создаём список туров (разных типов)
    tours = [
        Tour(2, "Петрова Мария", "Италия", 5, 95000.00),
        VipTour(3, "Сидоров Алексей", "ОАЭ", 10, 320000.00,
               "Олег Петров", True, "5 звёзд, президентский люкс"),
        Tour(4, "Козлова Елена", "Турция", 8, 210000.00),
        VipTour(6, "Соколова Анна", "ОАЭ", 4, 85000.00,
               "Ирина Соколова", False, "4 звёзды")
    ]
    
    # Полиморфный вызов: каждый объект вызывает свою реализацию
    for tour in tours:
        print(f"\n--- Обработка тура #{tour.tour_id} ---")
        tour.display_info()
        
        # Проверяем тип объекта
        if isinstance(tour, VipTour):
            print(f"\n VIP-статус: {tour.get_vip_status()}")
            print(f"👤 Менеджер: {tour.personal_manager}")
        else:
            print(f"\n Тип: Обычный тур")
        
        # Вызов метода скидки (полиморфизм)
        discount = tour.calculate_discount()
        final_price = tour.total_cost - discount
        print(f"Итоговая цена: {final_price:,.2f} руб.")
    
    
    # 4. СРАВНЕНИЕ МЕТОДОВ
    
    print("\n\n" \
    "СРАВНЕНИЕ МЕТОДОВ БАЗОВОГО И ПРОИЗВОДНОГО КЛАССОВ:")
    print("-"*40)
    
    print("\nБАЗОВЫЙ КЛАСС (Обычный тур):")
    base_tour = Tour(7, "Егорова Наталья", "Турция", 9, 120000.00)
    base_tour.display_info()
    print(f"\nСкидка: {base_tour.calculate_discount():,.2f} руб.")
    
    print("\nПРОИЗВОДНЫЙ КЛАСС (VIP-тур):")
    derived_tour = VipTour(8, "Морозов Сергей", "Греция", 10, 280000.00,
                          "Дмитрий Волков", True, "5 звёзд, с видом на море")
    derived_tour.display_info()
    print(f"\nСкидка: {derived_tour.calculate_discount():,.2f} руб.")
    
    # =========================================
    
    # 5. ИТОГИ
    # =========================================
    print("\n\n" + "="*50)
    print("ИТОГИ ТЕСТИРОВАНИЯ:")
    print("="*50)
    
    print("""
Базовый класс (Tour):
   - Хранит основную информацию о туре
   - Методы: display_info(), calculate_discount(), 
     check_duration(), get_final_price()

Производный класс (VipTour):
   - Наследует всё от базового класса
   - Добавляет: personal_manager, has_transfer, hotel_class
   - Переопределяет: display_info(), calculate_discount()
   - Добавляет новые методы: get_vip_status(), get_vip_service()

Полиморфизм:
   - Один интерфейс (Tour) - разные реализации
   - Обычный тур: скидка 5%
   - VIP-тур: скидка 15%
   - Разное отображение информации

Наследование:
   - VipTour наследует все методы Tour
   - Использует super() для вызова методов родителя
   - Может расширять функциональность
    """)
    
    print("\nНажмите Enter для выхода...")
    input()

# Запуск прораммы
if __name__ == "__main__":
    main()