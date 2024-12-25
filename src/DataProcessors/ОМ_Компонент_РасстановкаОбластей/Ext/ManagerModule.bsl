﻿#Область ПрограммныйИнтерфейс

Процедура ДобавитьКомандыДействий(КомандыДействий) Экспорт
	НоваяСтрока = КомандыДействий.Добавить();
	НоваяСтрока.Представление = "Расстановка областей";
	НоваяСтрока.Идентификатор = "РасстановкаОбластей";
	НоваяСтрока.Порядок = 20;
	НоваяСтрока.СпособЗапускаДействия = "ВызовМетодаМодуляМенеджера";
КонецПроцедуры

Функция ДеревоСтруктурыМодулейСоСтандартнымиОбластями(ДеревоСтруктуры) Экспорт
	Возврат ОбработкаРасстановкиОбластей().ДеревоСтруктурыМодулейСоСтандартнымиОбластями(ДеревоСтруктуры);
КонецФункции

Функция ДобавитьМодульСоСтандартнымиОбластями(СтрМодуль, НовоеДеревоСтруктуры) Экспорт
	Возврат ОбработкаРасстановкиОбластей().ДобавитьМодульСоСтандартнымиОбластями(СтрМодуль, НовоеДеревоСтруктуры);
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОбработкаРасстановкиОбластей()
	Возврат Обработки.ОМ_Компонент_РасстановкаОбластей.Создать();
КонецФункции

#КонецОбласти

