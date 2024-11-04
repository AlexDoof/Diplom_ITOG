// В модуле реализуйте метод, который получает на вход текст сообщения
// В рамках метода:
// создайте защищённое соединение с сервером "api.telegram.org"
// создайте HTTP-запрос к ресурсу /bot[ВашТокен]/sendMessage
// добавьте заголовок "Content-Type" со значением "application/json"
// подготовьте структуру с полями:
// "chat_id" - идентификатор группы из константы,
// "text" - текст сообщения
// установите JSON строку, полученную из структуры, в качестве тела HTTP-запроса
// отправьте запрос с помощью метода "POST"
// проверьте, что получет ответ с кодом состояния 200, если код состояния отличный от 200, 
// получите тело ответа как строку и запишите в журнал регистрации информацию об ошибке. 

#Область СлужебныеПроцедурыИФункции  


Процедура ВзаимодействиеСТелеграмБотом(ТекстСообщения, Ссылка) Экспорт
	
	// Переменные
	ID_группыВТелеграме = Константы.ВКМ_ИдентификаторГруппыДляОповещения.Получить(); 
	ТокенУправленияТГБотом = Константы.ВКМ_ТокенУправленияТГБотом.Получить(); 
	АдресСервераТелеграм = "api.telegram.org";  
	Ресурс = "/bot" + ТокенУправленияТГБотом + "/sendMessage";
	Заголовок_ContentType = "application/json";
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", Заголовок_ContentType);
	
	//Структура для JSON
	СтруктураЗапроса = Новый Структура;
	СтруктураЗапроса.Вставить("chat_id", ID_группыВТелеграме);
	СтруктураЗапроса.Вставить("text", ТекстСообщения);
	
	// Создание JSON       
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, СтруктураЗапроса);
	СтрокаJSON = ЗаписьJSON.Закрыть(); 
	
	//HTTP-соединение
	ПараметрыПодключения = ПараметрыПодключения(АдресСервераТелеграм, Ресурс);
	Соединение = Новый HTTPСоединение(ПараметрыПодключения.АдресСервераТелеграм,,,,,,ПараметрыПодключения.ЗащищенноеСоединение);
	
	//HTTP-запрос
	Запрос = Новый HTTPзапрос(ПараметрыПодключения.Ресурс, Заголовки); 
	Запрос.УстановитьТелоИзСтроки(СтрокаJSON); 
	
	//Получаем элемент справочника и првоеряем его на отправленность
	ОбъектСообщение = Ссылка.ПолучитьОбъект();
	Если НЕ ОбъектСообщение.Отправлено Тогда
		Ответ = Соединение.Получить(Запрос); //<- отправка в ТГ
		
		Если Ответ.КодСостояния <> 200 Тогда
			ОбщегоНазначения.СообщитьПользователю("Ошибка проверки подключения к телеграм-боту"); 
			ТекстОтвета = Ответ.ПолучитьТелоКакСтроку();   
			Комментарий = "Не удалось подключиться к ТГ-боту, ответ сервера " + Ответ.КодСостояния + " // " + ТекстОтвета;    
			ЗаписьЖурналаРегистрации("Отказ Телеграм-бота", УровеньЖурналаРегистрации.Информация,,,Комментарий);
			ОбщегоНазначения.СообщитьПользователю("Сообщение НЕ отправлено ..."); 
			Возврат;
		КонецЕсли;
		ОбщегоНазначения.СообщитьПользователю("Сообщение отправлено в Телеграм бот...");
		ОбъектСообщение.Отправлено = Истина; 
		ОбъектСообщение.Записать();
	КонецЕсли;    
		
КонецПроцедуры


Функция ПараметрыПодключения(АдресСервераТелеграм, Ресурс)  
	
	Результат = Новый Структура;
	Результат.Вставить("АдресСервераТелеграм", АдресСервераТелеграм);
	Результат.Вставить("Ресурс", Ресурс);  
	Результат.Вставить("ЗащищенноеСоединение", Новый ЗащищенноеСоединениеOpenSSL);
	
	Возврат Результат;
	
КонецФункции


Процедура ВКМ_ОтправкаУведомленийВТГ() Экспорт
	//Регл. задание	
	Запрос = Новый запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_УведомленияТелеграмБоту.ТекстСообщения КАК ТекстСообщения,
	|	ВКМ_УведомленияТелеграмБоту.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВКМ_УведомленияТелеграмБоту КАК ВКМ_УведомленияТелеграмБоту"; 
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл   
		//Отправка сообщения
		ВзаимодействиеСТелеграмБотом(Выборка.ТекстСообщения, Выборка.Ссылка);  
		
		//Удаление Сообщения из справочника если реквизит "Отправлено" = Истина  
		ОбъектСообщение = Выборка.Ссылка.ПолучитьОбъект();
		Если ОбъектСообщение.Отправлено Тогда
			ОбъектСообщение.Удалить();           
		КонецЕсли;
	КонецЦикла; 
КонецПроцедуры


#КонецОбласти
