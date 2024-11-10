	
#Область ОбработчикиСобытий    
	
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
		
		// Проверка,если выбран договор с типом абонентская плата - что дата документа
		// лежит между датой начала и датой окончания действия договора
		
	Если Договор.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.АбонентскоеОбслуживание Тогда  
			
		Если НЕ (Дата > Договор.ВКМ_НачалоДействияДоговора И Дата < Договор.ВКМ_КонецДействияДоговора) Тогда
			Отказ = Истина;
			ОбщегоНазначения.СообщитьПользователю("Дата документа не попадает в рамки действия выбранного договора");
			Возврат;	
		КонецЕсли; 
			
		// Движение по регистру ВыполненныеКлиентуРаботы   
			
		Движения.ВКМ_ВыполненныеКлиентуРаботы.Очистить();
		Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина;   
			
		СтавкаЧаса = Договор.ВКМ_СтоимостьЧасаРаботыСпециалиста;
		КоличествоЧасов = ВыполненныеРаботы.Итог("ЧасыКОплатеКлиенту");
			
		Движение = Движения.ВКМ_ВыполненныеКлиентуРаботы.ДобавитьПриход(); 
		Движение.Период = Дата;
		Движение.Клиент = Клиент; 
		Движение.Договор = Договор;
		Движение.КоличествоЧасов = КоличествоЧасов; 
		Движение.СуммаКОплате = КоличествоЧасов * СтавкаЧаса;
			
	КонецЕсли;   
		
		
	//Движение по регистру накопления ВыполненныеСотрудникомРаботы
	Отбор = Новый Структура("Сотрудник", Специалист);  
	Попытка
			ПроцентОтВыполненныхРабот = РегистрыСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(Дата,Отбор)[0].ПроцентЗаВыполненныеРаботы;
	Исключение  
			ОбщегоНазначения.СообщитьПользователю("Для текущего специалиста не установлен % за выпол. работы");
	КонецПопытки;
		
	Если ПроцентОтВыполненныхРабот = Null ИЛИ ПроцентОтВыполненныхРабот = Неопределено Тогда   
			Отказ = Истина;
			Возврат;
	КонецЕсли; 
		
	Если ПроцентОтВыполненныхРабот >= 0 Тогда 
			Движения.ВКМ_ВыполненныеСотрудникомРаботы.Очистить();
			Движения.ВКМ_ВыполненныеСотрудникомРаботы.Записывать = Истина; 
			Движение = Движения.ВКМ_ВыполненныеСотрудникомРаботы.ДобавитьПриход(); 
			Движение.Период = Дата;
			Движение.Сотрудник = Специалист;
			Движение.ЧасовКОплате = КоличествоЧасов; 
			Движение.СуммаКОплате = КоличествоЧасов * СтавкаЧаса * ПроцентОтВыполненныхРабот/100;
	КонецЕсли;
		
КонецПроцедуры
	
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)   
		
	ЭтотДокументНовый = ЭтотОбъект.ЭтоНовый();   	
	Если ЭтотДокументНовый ИЛИ ЕстьИзмененияВДокументе() Тогда         			
		СформироватьУведомлениеДляТГ(); 
	КонецЕсли;   
		
	КонецПроцедуры 	
	
#КонецОбласти  
	
#Область СлужебныеПроцедурыИФункции
Функция ЕстьИзмененияВДокументе()
	Результат = Ложь;  
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_ОбслуживаниеКлиента.ДатаПроведенияРабот КАК ДатаПроведенияРабот,
	|	ВКМ_ОбслуживаниеКлиента.Специалист КАК Специалист,
	|	ВКМ_ОбслуживаниеКлиента.Клиент КАК Клиент
	|ИЗ
	|	Документ.ВКМ_ОбслуживаниеКлиента КАК ВКМ_ОбслуживаниеКлиента
	|ГДЕ
	|	ВКМ_ОбслуживаниеКлиента.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	Если Выборка.ДатаПроведенияРабот <> ДатаПроведенияРабот ИЛИ
		Выборка.Специалист <> Специалист ИЛИ
		Выборка.Клиент <> Клиент Тогда
		Результат = Истина;
	КонецЕсли;
		
	Возврат Результат;  
		
КонецФункции
	
Процедура СформироватьУведомлениеДляТГ()
	НовоеУведомление = Справочники.ВКМ_УведомленияТелеграмБоту.СоздатьЭлемент();	
	ТекстУведомления = СтрШаблон("Специалист: %1 
	|Клиент: %2 
	|Договор: %3 
	|Дата проведения работ: %4 
	|Описание проблемы: %5", Специалист, Клиент, Договор, ДатаПроведенияРабот, ОписаниеПроблемы); 
		
	НовоеУведомление.ТекстСообщения = ТекстУведомления;
	НовоеУведомление.Записать();     
		
КонецПроцедуры 
	
#КонецОбласти  
	
