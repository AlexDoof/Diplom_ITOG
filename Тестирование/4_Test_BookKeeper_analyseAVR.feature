﻿#language: ru

@tree

Функционал: формирование отчета Анализ выставленных актов

Как бухгалтер я хочу
составить отчет Анализ выставленных актов 
чтобы протестирвоать и продемонстрировать этот функционал  

// Период на тестах вводить вручную!!! Данный тест выполнять после всех предыдущих согласно порядковому ноеру в имени файла
// Отчет показывает данные по документам обслуживание клиентов. 
// То есть суммы к оплате за выбранный период (за работы специалистов сверх абон.платы_
Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий

Сценарий: составление отчета Анализ выставленных актов
И В командном интерфейсе я выбираю "ДобавленныеОбъекты" "Анализ выставленных актов"
Тогда открылось окно "Основной"
И я нажимаю на кнопку с именем 'ВыбратьПериод1'
Тогда открылось окно "Выберите период"
И в поле с именем 'DateBegin' я ввожу текст "01.02.2024"
И я перехожу к следующему реквизиту
И в поле с именем 'DateEnd' я ввожу текст "29.02.2024"
И я перехожу к следующему реквизиту
И я нажимаю на кнопку с именем 'Select'
Тогда открылось окно "Основной"
И я нажимаю на кнопку с именем 'СформироватьОтчет'


