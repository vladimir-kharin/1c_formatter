﻿#Область ПрограммныйИнтерфейс

// Добавляет новую строку команды действий с предустановленными значениями идентификатора и представления.
// 
// Параметры:
//  КомандыДействий - ТаблицаЗначений - Таблица, в которую добавляется новая строка действия.
Процедура ДобавитьКомандыДействий(КомандыДействий) Экспорт
	НоваяСтрока = КомандыДействий.Добавить();
	НоваяСтрока.Представление = "Сформировать тексты модулей...";
	НоваяСтрока.Идентификатор = "ГенерацияТекстов";
	НоваяСтрока.Порядок = 1000;
	НоваяСтрока.СпособЗапускаДействия = "ОткрытиеФормы";
КонецПроцедуры

// Создает соответствие, связывающее элементы структуры с их текстами модулей
// 
// Параметры:
//  ДеревоСтруктуры - Объект - Структурное дерево, содержащее строки с элементами модулей
// 
// Возвращаемое значение:
//  Соответствие - Ассоциация строк модулей с текстами их модулей
Функция СоответствиеТекстыМодулей(ДеревоСтруктуры) Экспорт
	ПроверитьИнструкцииПрепроцессораПоДеревуСтруктуры(ДеревоСтруктуры);
	
	СоотвМодулей = Новый Соответствие;
	
	Для каждого СтрМодуль Из ДеревоСтруктуры.Строки Цикл
		ТекстМодуля = ТекстМодуля(СтрМодуль);
		СоотвМодулей.Вставить(СтрМодуль, ТекстМодуля);
	КонецЦикла;
	
	Возврат СоотвМодулей;
КонецФункции

// Возвращает текст элемента модуля
// 
// Параметры:
//  СтрЭлементМодуль - Объект - Элемент модуля для генерации его текста
// 
// Возвращаемое значение:
//  Строка - Текст модуля элемента
Функция ТекстМодуля(СтрЭлементМодуль) Экспорт
	Возврат ОбработкаГенерацииТекста().ТекстМодуля(СтрЭлементМодуль);
КонецФункции

// Генерирует текстовое представление метода с возможностью включения кода / документации отдельно
// 
// Параметры:
//  СтрЭлементМетод      - Неизвестно - Элемент или ссылка на метод, текст которого нужно сгенерировать
//  ВключатьКод          - Булево     - Опционально. Включает код в сгенерированный текст. По умолчанию Истина
//  ВключатьДокументацию - Булево     - Опционально. Включает документацию. По умолчанию Истина
//  ТолькоСигнатура      - Булево     - Опционально. Генерирует только сигнатуру метода. По умолчанию Ложь
// 
// Возвращаемое значение:
//  Строка - Сгенерированный текст метода
Функция ГенерироватьТекстМетода(СтрЭлементМетод, ВключатьКод = Истина, ВключатьДокументацию = Истина, ТолькоСигнатура = Ложь) Экспорт
	Возврат ОбработкаГенерацииТекста().ГенерироватьТекстМетода(СтрЭлементМетод, ВключатьКод, ВключатьДокументацию, ТолькоСигнатура);
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОбработкаГенерацииТекста()
	Возврат Обработки.ОМ_Компонент_ГенерацияТекстовМодулей.Создать();
КонецФункции

Процедура ПроверитьИнструкцииПрепроцессораПоДеревуСтруктуры(ДеревоСтруктуры)
	Для каждого СтрМодуль Из ДеревоСтруктуры.Строки Цикл
		ПроверитьИнструкцииПрепроцессора(СтрМодуль);
	КонецЦикла;
КонецПроцедуры

Процедура ПроверитьИнструкцииПрепроцессора(СтрЭлемент)
	Если СтрЭлемент.Содержимое.Свойство("ИнструкцииПрепроцессора") Тогда
		
		Если Не ИнструкцииПрепроцессораКорректные(СтрЭлемент.Содержимое.ИнструкцииПрепроцессора) Тогда
			
			ТекстИсключения = "У элемента " + СтрЭлемент.Содержимое.Имя + " указаны некорректные инструкции препроцессора.";
			ВызватьИсключение ТекстИсключения;
	
		КонецЕсли; 
		
	КонецЕсли;
	
	Для каждого СтрВложенныйЭлемент Из СтрЭлемент.Строки Цикл
		ПроверитьИнструкцииПрепроцессора(СтрВложенныйЭлемент)	
	КонецЦикла;
КонецПроцедуры

Функция ИнструкцииПрепроцессораКорректные(ИнструкцииПрепроцессора)
	ЕстьИнструкции = Ложь;
	Для каждого КлючИЗначение Из ИнструкцииПрепроцессора Цикл
		Если КлючИЗначение.Значение = Истина Тогда
			ЕстьИнструкции = Истина;
			Прервать;
		КонецЕсли; 		
	КонецЦикла; 
	
	Возврат ЕстьИнструкции;
КонецФункции

#КонецОбласти

