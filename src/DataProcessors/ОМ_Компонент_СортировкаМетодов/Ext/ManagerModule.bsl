﻿#Область ПрограммныйИнтерфейс

// Добавляет команды действий в переданный список команд
// 
// Параметры:
//  КомандыДействий - Список - Список, в который добавляются команды действий.
Процедура ДобавитьКомандыДействий(КомандыДействий) Экспорт

	НоваяСтрока = КомандыДействий.Добавить();
	НоваяСтрока.Представление = "Сортировка методов";
	НоваяСтрока.Идентификатор = "СортировкаМетодов";
	НоваяСтрока.ОбластьДействия = "Область,Процедура,Функция";
	НоваяСтрока.Порядок = 700;
	НоваяСтрока.СпособЗапускаДействия = "ВызовМетодаМодуляМенеджера";
	
	НоваяСтрока = КомандыДействий.Добавить();
	НоваяСтрока.Представление = "Сортировка служебных методов";
	НоваяСтрока.Идентификатор = "СортировкаСлужебныхМетодов";
	НоваяСтрока.Порядок = 701;
	НоваяСтрока.СпособЗапускаДействия = "ВызовМетодаМодуляМенеджера";

КонецПроцедуры // ДобавитьКомандыДействий()

// Выполняет действие на основании идентификатора команды.
// 
// Параметры:
//  ИдКоманды        - Строка    - Идентификатор команды для выполнения действия.
//  ПараметрыКоманды - Структура - Параметры команды, включает ДеревоСтруктурыМодулей.
Процедура ВыполнитьДействие(ИдКоманды, ПараметрыКоманды) Экспорт

	Если ИдКоманды = "СортировкаМетодов" Тогда
		СортировкаМетодов(ПараметрыКоманды);
	ИначеЕсли ИдКоманды = "СортировкаСлужебныхМетодов" Тогда
		СортировкаСлужебныхМетодов(ПараметрыКоманды);
	КонецЕсли;

КонецПроцедуры // ВыполнитьДействие()

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура СортировкаМетодов(ПараметрыКоманды)

	ДеревоСтруктурыМодулей = ПараметрыКоманды.ДеревоСтруктурыМодулей;
	
	ВыбраннаяСтрока = Обработки.ОМ_ОформляторМодулей.НайтиВыбраннуюСтроку(ДеревоСтруктурыМодулей);
	
	Если ВыбраннаяСтрока.ТипЭлемента = "Область" Тогда
		Строки = ВыбраннаяСтрока.Строки;
	Иначе
		Если ВыбраннаяСтрока.Родитель = Неопределено Тогда
			Возврат;
		КонецЕсли;
		Строки = ВыбраннаяСтрока.Родитель.Строки;
	КонецЕсли;

	ДеревоСтруктурыМодулей.Колонки.Добавить("ПолеСортировки");

	СортироватьЭлементыОбласти(Строки);

	ДеревоСтруктурыМодулей.Колонки.Удалить("ПолеСортировки");

КонецПроцедуры // СортировкаМетодов()	

// Выполняет сортировку методов в области СлужебныеПроцедурыИФункции или Private
// 
// Параметры:
//  ПараметрыКоманды - Структура - Параметры команды с деревом структуры модуля
Процедура СортировкаСлужебныхМетодов(ПараметрыКоманды)
	
	ДеревоСтруктурыМодулей = ПараметрыКоманды.ДеревоСтруктурыМодулей;
	
	// Найдем область СлужебныеПроцедурыИФункции
	ОбластьСлужебныхМетодов = Обработки.ОМ_ОформляторМодулей.НайтиОбластьПоИмени(ДеревоСтруктурыМодулей, "СлужебныеПроцедурыИФункции");
	Если ОбластьСлужебныхМетодов = Неопределено Тогда
		ОбластьСлужебныхМетодов = Обработки.ОМ_ОформляторМодулей.НайтиОбластьПоИмени(ДеревоСтруктурыМодулей, "Private");
		Если ОбластьСлужебныхМетодов = Неопределено Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Добавляем колонку для сортировки
	ДеревоСтруктурыМодулей.Колонки.Добавить("ПолеСортировки");
	
	// Сортируем элементы в области
	СортироватьЭлементыОбласти(ОбластьСлужебныхМетодов.Строки);
	
	// Удаляем временную колонку
	ДеревоСтруктурыМодулей.Колонки.Удалить("ПолеСортировки");
	
КонецПроцедуры // СортировкаСлужебныхМетодов()

Процедура СортироватьЭлементыОбласти(СтрокиДереваМодуля)

	Если СтрокиДереваМодуля.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	// Сначала рекурсивно сортируем содержимое всех областей
	Для Каждого ТекСтрока Из СтрокиДереваМодуля Цикл
		Если ТекСтрока.ТипЭлемента = "Область" Тогда
			СортироватьЭлементыОбласти(ТекСтрока.Строки);
		КонецЕсли;
	КонецЦикла;
	
	// Заполняем поле сортировки для каждой строки
	Для Каждого ТекСтрока Из СтрокиДереваМодуля Цикл
		Если ТекСтрока.ТипЭлемента = "Область" Тогда
			// Области размещаем в начале списка, добавляя префикс "0"
			ТекСтрока.ПолеСортировки = "0" + ТекСтрока.Содержимое.Имя;
		Иначе
			ТекСтрока.ПолеСортировки = ТекСтрока.Содержимое.Имя;
		КонецЕсли;
	КонецЦикла;
	
	// Сортируем строки по полю сортировки
	СтрокиДереваМодуля.Сортировать("ПолеСортировки");

КонецПроцедуры // СортироватьЭлементыОбласти()

#КонецОбласти
