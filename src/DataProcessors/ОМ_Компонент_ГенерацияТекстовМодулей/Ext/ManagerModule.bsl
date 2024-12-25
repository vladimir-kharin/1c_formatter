﻿#Область ПрограммныйИнтерфейс

Процедура ДобавитьКомандыДействий(КомандыДействий) Экспорт
	НоваяСтрока = КомандыДействий.Добавить();
	НоваяСтрока.Представление = "Генерация текстов модулей";
	НоваяСтрока.Идентификатор = "ГенерацияТекстов";
	НоваяСтрока.Порядок = 10;
	НоваяСтрока.СпособЗапускаДействия = "ОткрытиеФормы";
КонецПроцедуры

Функция СоответствиеТекстыМодулей(ДеревоСтруктуры) Экспорт
	ПроверитьИнструкцииПрепроцессораПоДеревуСтруктуры(ДеревоСтруктуры);
	
	СоотвМодулей = Новый Соответствие;
	
	Для каждого СтрМодуль Из ДеревоСтруктуры.Строки Цикл
		ТекстМодуля = ТекстМодуля(СтрМодуль);
		СоотвМодулей.Вставить(СтрМодуль, ТекстМодуля);
	КонецЦикла;
	
	Возврат СоотвМодулей;
КонецФункции

Функция ТекстМодуля(СтрЭлементМодуль) Экспорт
	Возврат ОбработкаГенерацииТекста().ТекстМодуля(СтрЭлементМодуль);
КонецФункции

Функция ГенерироватьТекстМетода(СтрЭлементМетод, ВключатьКод = Истина, ВключатьДокументацию = Истина, ТолькоСигнатура = Ложь) Экспорт
	Возврат ОбработкаГенерацииТекста().МетодТекст(СтрЭлементМетод, ВключатьКод, ВключатьДокументацию, ТолькоСигнатура);
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

