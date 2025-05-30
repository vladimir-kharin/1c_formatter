﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	// Заполнение параметров из переданных значений
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Параметры, "БазовыйАдрес,КлючAPI,Модель,СпособДокументирования");

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Принять(Команда)

	РезультатЗакрытия = Новый Структура;
	РезультатЗакрытия.Вставить("БазовыйАдрес", БазовыйАдрес);
	РезультатЗакрытия.Вставить("КлючAPI", КлючAPI);
	РезультатЗакрытия.Вставить("Модель", Модель);
	РезультатЗакрытия.Вставить("СпособДокументирования", СпособДокументирования);
	
	Закрыть(РезультатЗакрытия);

КонецПроцедуры

#КонецОбласти
