#Область СобытияДокумента  

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Очистить();
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	
	Для Каждого Строка из Выплаты Цикл    
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Сотрудник = Строка.Сотрудник;
		Движение.Сумма = Строка.Сумма;
	КонецЦикла;
КонецПроцедуры  

#КонецОбласти


