#Область ПрограмныйИнтерфейс 
Процедура ОбработкаПроведения(Отказ, Режим)    
	// 1. Установка маркера Записи у регистров
	Движения.ВКМ_ДополнительныеНачисления.Записывать = Истина;  
	Движения.ВКМ_Удержания.записывать = Истина;
	
	// 2. Движения по регистру расчета ДополнительныеНачисления
	Для Каждого ТекСтрокаТаблица Из Таблица Цикл  
		
		ДвижениеДН = Движения.ВКМ_ДополнительныеНачисления.Добавить(); 
		ДвижениеДН.ВидРасчета = ПланыВидовРасчета.ВКМ_ДополнительныеНачисления.Премия;
		ДвижениеДН.ПериодРегистрации = БазовыйПериодНачало;
		ДвижениеДН.Сотрудник = ТекСтрокаТаблица.Сотрудник; 
		ДвижениеДН.СуммаКОплате = ТекСтрокаТаблица.СуммаПремии;
		
		// 3. Движения по регистру расчета Удержания
		ДвижениеУд = Движения.ВКМ_Удержания.Добавить();
		ДвижениеУд.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		ДвижениеУд.ПериодРегистрации = Дата;
		ДвижениеУд.Сотрудник = ТекСтрокаТаблица.Сотрудник; 
		ДвижениеУд.БазовыйПериодНачало = БазовыйПериодНачало;
		ДвижениеУд.БазовыйПериодКонец = БазовыйПериодКонец;
		ДвижениеУд.Начисление = ТекСтрокаТаблица.СуммаПремии;
	КонецЦикла; 
	Движения.Записать(); 
	
	// 4. Расчет удержаний 
	РассчитатьУдержания(Движения.ВКМ_Удержания, Ссылка);
	
	ВзаиморасчетыССотрудниками();
	
КонецПроцедуры  
#КонецОбласти


#Область СлужебныеПроцедурыИФункции

Процедура РассчитатьУдержания(НаборЗаписей,РегистраторСсылка) 
	ПроцентНДФЛ = Константы.ВКМ_ПроцентНДФЛ.Получить();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_Удержания.НомерСтроки КАК НомерСтроки,
	|	ВКМ_Удержания.ВидРасчета КАК ВидРасчета,
	|	ВКМ_Удержания.Начисление КАК Начисление,
	|	ЕСТЬNULL(ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления.СуммаКОплатеБаза, 0) КАК База
	|ИЗ
	|	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания.БазаВКМ_ДополнительныеНачисления(&Измерения, &Измерения, , Регистратор = &Регистратор) КАК ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления
	|		ПО ВКМ_Удержания.НомерСтроки = ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления.НомерСтроки
	|ГДЕ
	|	ВКМ_Удержания.Регистратор = &Регистратор";
	
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	
	Запрос.УстановитьПараметр("Регистратор", РегистраторСсылка);
	Запрос.УстановитьПараметр("Измерения", Измерения);
	
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	//Определение структуры для поиска по номеру строки
	Поиск = Новый Структура("НомерСтроки",0);   
	
	Для Каждого Запись Из НаборЗаписей Цикл    
		Поиск.НомерСтроки = Запись.НомерСтроки;
		// Поиск нужной строки выборки по номеру строки
		Если Выборка.НайтиСледующий(Поиск) Тогда
			
			Если Выборка.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ Тогда 
				//  Расчет НДФЛ  процентом от премии
				Запись.СуммаУдержания = Выборка.База * ПроцентНДФЛ / 100;     
			КонецЕсли; 
			
		КонецЕсли; 
	КонецЦикла;     
	
	// Позицию выборки необходимо сбросить в начало
	Выборка.Сбросить();    
	
	// Запись набора
	НаборЗаписей.Записать();
	
КонецПроцедуры

Процедура ВзаиморасчетыССотрудниками()  
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;  
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Очистить();
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.текст = "ВЫБРАТЬ
|	ВКМ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
|	СУММА(ВКМ_ДополнительныеНачисления.СуммаКОплате) КАК СуммаКОплате
|ПОМЕСТИТЬ ВТ_ДОП_НАЧИСЛЕНИЯ
|ИЗ
|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
|ГДЕ
|	ВКМ_ДополнительныеНачисления.Регистратор = &Ссылка
|
|СГРУППИРОВАТЬ ПО
|	ВКМ_ДополнительныеНачисления.Сотрудник
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ВТ_ДОП_НАЧИСЛЕНИЯ.Сотрудник КАК Сотрудник,
|	ВТ_ДОП_НАЧИСЛЕНИЯ.СуммаКОплате КАК СуммаКОплате,
|	ВКМ_Удержания.СуммаУдержания КАК СуммаУдержания
|ИЗ
|	ВТ_ДОП_НАЧИСЛЕНИЯ КАК ВТ_ДОП_НАЧИСЛЕНИЯ
|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
|		ПО (ВТ_ДОП_НАЧИСЛЕНИЯ.Сотрудник = ВКМ_Удержания.Сотрудник)
|ГДЕ
|	ВКМ_Удержания.Регистратор = &Ссылка";	
	Запрос.УстановитьПараметр("ПериодДействияНачало",БазовыйПериодНачало);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	Пока Выборка.Следующий() Цикл   
	Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	Движение.Период = Дата;
	Движение.Сотрудник = Выборка.Сотрудник;
	Движение.Сумма = Выборка.СуммаКОплате - Выборка.СуммаУдержания;
	//Движение.ДатаДокумента = Дата;
	КонецЦикла;
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();  
	
КонецПроцедуры

#КонецОбласти
