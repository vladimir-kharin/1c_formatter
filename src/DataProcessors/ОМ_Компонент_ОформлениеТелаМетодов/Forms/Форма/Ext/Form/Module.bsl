﻿// Репозиторий проекта: 
// https://github.com/vladimir-kharin/1c_formatter
// 
// Харин Владимир (С) 2025. https://vharin.ru
// Telegram - https://t.me/vladimir_kharin

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("ПараметрыКоманды") Тогда
		АдресДереваСтруктурыМодулей = Параметры.ПараметрыКоманды.АдресДереваСтруктурыМодулей;
		дз = ПолучитьИзВременногоХранилища(АдресДереваСтруктурыМодулей);
		Если Параметры.ПараметрыКоманды.Идентификатор = "ОформлениеМетодаСНастройкой" Тогда
			дз.Колонки.Добавить("НомерСтрокиВМетодыКОформлению");
			
			ВыбраннаяСтрока = Обработки.ОМ_ОформляторМодулей.НайтиВыбраннуюСтроку(дз);
			
			МассивМетодов = Новый Массив;
			Если ВыбраннаяСтрока.ТипЭлемента = "Процедура" ИЛИ ВыбраннаяСтрока.ТипЭлемента = "Функция" Тогда
				МассивМетодов.Добавить(ВыбраннаяСтрока);
			ИначеЕсли ВыбраннаяСтрока.ТипЭлемента = "Область" ИЛИ ВыбраннаяСтрока.ТипЭлемента = "Модуль" Тогда
				МассивМетодов = Обработки.ОМ_ОформляторМодулей.НайтиПодчиненныеСтроки(ВыбраннаяСтрока, "Процедура,Функция");
			КонецЕсли;
			
			ОдинМетод = (МассивМетодов.Количество() = 1);
			
			НомерСтроки = 1;
			Для каждого СтрМетод Из МассивМетодов Цикл
				Метод = МетодыКОформлению.Добавить();
				ЗаполнитьЗначенияСвойств(Метод, СтрМетод.Содержимое, "Имя,ЭтоФункция,Тело");
				Метод.Пометка = Истина;
				Метод.НомерКартинки = ?(Метод.ЭтоФункция, 1, 0);
				
				СтрМетод.НомерСтрокиВМетодыКОформлению = НомерСтроки;
				НомерСтроки = НомерСтроки + 1;
			КонецЦикла;
	
			ПоместитьВоВременноеХранилище(дз, АдресДереваСтруктурыМодулей);
			
			// Устанавливаем текущую страницу в зависимости от количества методов
			Элементы.СтраницыОдинНесколько.ТекущаяСтраница = ?(ОдинМетод,
				Элементы.СтраницаОдинМетод,
				Элементы.СтраницаНесколькоМетодов);
				
			Если Не ЗначениеЗаполнено(ПравилаОформления) Тогда
				ПравилаОформления =
				"- Приведи написание ключевых слов и стандартных методов платформы к каноническому виду (если/ЕСЛИ -> Если, тогда/ТОГДА - > Тогда, и так далее).
				|- Оформи отступы. Стандартный отступ - одна табуляция. Если отступы сделаны пробелами - переделай на табуляции.
				|- В одной строке кода должно быть не более одного оператора.";
			КонецЕсли;
		КонецЕсли;
	Иначе
		ВызватьИсключение "В форму должен быть передан параметр ПараметрыКоманды.АдресДереваСтруктурыМодулей";
	КонецЕсли;
	
	ПроверитьКодПослеОформления = Истина;
	ПравилаИзменения = "";
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Элементы.МетодыКОформлению.ТекущаяСтрока = МетодыКОформлению[0].ПолучитьИдентификатор();
	УстановитьВидимостьДоступностьЭлементовФормы();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПроверитьКодПослеОформленияПриИзменении(Элемент)
	УстановитьВидимостьДоступностьЭлементовФормы();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Оформить(Команда)
	Для каждого Метод Из МетодыКОформлению Цикл
		Если НЕ Метод.Пометка Тогда
			Продолжить;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(КлючAPI) Тогда
			Если ПроверитьКодПослеОформления Тогда
				ТекстПромпта = СформироватьПромптДляОформленияКода(Метод.Тело);
			Иначе
				ТекстПромпта = СформироватьПромптДляСвободногоОформленияКода(Метод.Тело);
			КонецЕсли;
			ОтветМоделиСтр = КлиентИИ.ОтправитьЗапросOpenAI(ТекстПромпта, КлючAPI, БазовыйАдрес, Модель);
		Иначе
			ОтветМоделиСтр = ОформитьМетодСервисомПоУмолчанию(Метод);
		КонецЕсли;
		
		ТелоОформленное = ВыделитьКодИзОтвета(ОтветМоделиСтр);
		МетодОформлен = Истина;
		Если ПроверитьКодПослеОформления Тогда
			Если ЕстьСущественныеОтличияКодаПослеОформления(Метод.Тело, ТелоОформленное) Тогда
				СообщениеОбОшибке = СтрШаблон("Метод %1 не может быть оформлен. См. лог", Метод.Имя);

				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = СообщениеОбОшибке;
				Сообщение.Сообщить();

				МетодОформлен = Ложь;
			Иначе
				Метод.ТелоОформленное = ТелоОформленное;
			КонецЕсли;
		Иначе
			Метод.ТелоОформленное = ТелоОформленное;
		КонецЕсли;

		Если МетодыКОформлению.Количество() > 1 
			И МетодОформлен Тогда
			Метод.Пометка = Ложь;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ПринятьИЗакрыть(Команда)
	ПринятьИЗакрытьНаСервере();
	Закрыть(Новый Структура("АдресДереваСтруктурыМодулей", АдресДереваСтруктурыМодулей));
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПометки(Команда)
	Для каждого МетодКДокументированию Из МетодыКОформлению Цикл
		МетодКДокументированию.Пометка = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СнятьПометки(Команда)
	Для каждого МетодКДокументированию Из МетодыКОформлению Цикл
		МетодКДокументированию.Пометка = Ложь;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьВидимостьДоступностьЭлементовФормы()
	Если ПроверитьКодПослеОформления Тогда
		Элементы.ПроверитьКодПослеОформления.ЦветТекстаЗаголовка = Элементы.Метод.ЦветТекстаЗаголовка;
		Элементы.ПравилаИзменения.Видимость = Ложь;
	Иначе
		Элементы.ПроверитьКодПослеОформления.ЦветТекстаЗаголовка = WebЦвета.Красный;
		Элементы.ПравилаИзменения.Видимость = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ВыделитьКодИзОтвета(ОтветМоделиСтр)
	
	ТелоОформленное = "";

	// Проверяем, содержит ли ответ код в блоке, ограниченном символами "```"
	Если СтрНайти(ОтветМоделиСтр, "```") > 0 Тогда
		// Создаем текстовый документ для работы со строками
		ТекстДок = Новый ТекстовыйДокумент;
		ТекстДок.УстановитьТекст(ОтветМоделиСтр);
		
		// Поиск строк, начинающихся с ```
		НачальнаяСтрока = 0;
		КонечнаяСтрока = 0;
		
		Для НомерСтроки = 1 По ТекстДок.КоличествоСтрок() Цикл
			ТекСтрока = СокрЛ(ТекстДок.ПолучитьСтроку(НомерСтроки));
			
			Если Лев(ТекСтрока, 3) = "```" Тогда
				Если НачальнаяСтрока = 0 Тогда
					НачальнаяСтрока = НомерСтроки;
				Иначе
					КонечнаяСтрока = НомерСтроки;
					Прервать;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		// Если нашли корректный блок с кодом
		Если НачальнаяСтрока > 0 И КонечнаяСтрока > НачальнаяСтрока Тогда
			// Извлекаем строки между маркерами ```
			ТекстКода = Новый ТекстовыйДокумент;
			ПерваяСтрокаКода = НачальнаяСтрока + 1;
			
			// Копируем строки кода в новый документ
			Для НомерСтроки = ПерваяСтрокаКода По КонечнаяСтрока - 1 Цикл
				ТекстКода.ДобавитьСтроку(ТекстДок.ПолучитьСтроку(НомерСтроки));
			КонецЦикла;
			
			// Получаем весь текст кода
			ТелоОформленное = ТекстКода.ПолучитьТекст();
		Иначе
			// Если не нашли корректный блок кода, используем весь текст
			ТелоОформленное = ОтветМоделиСтр;
		КонецЕсли;
	Иначе
		// Если нет блоков кода, используем ответ как есть
		ТелоОформленное = ОтветМоделиСтр;
	КонецЕсли;
	
	Возврат ТелоОформленное;

КонецФункции

&НаСервереБезКонтекста
Функция ЕстьСущественныеОтличияКодаПослеОформления(ТелоДоОформления, ТелоОформленное)

	СущественныеОтличия = ОписаниеСущественныхОтличийПоТокенам(ТелоДоОформления, ТелоОформленное);
	
	Если ЗначениеЗаполнено(СущественныеОтличия) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СущественныеОтличия;
		Сообщение.Сообщить();

		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;
КонецФункции

&НаСервереБезКонтекста
Функция ОписаниеСущественныхОтличийПоТокенам(ТелоДоОформления, ТелоОформленное)
	Попытка
		ПарсерКодаДоОформления = Обработки.ОМ_Парсер_ПарсерВстроенногоЯзыка.Создать();
		ТаблицаТокенов_ДоОформления = ПарсерКодаДоОформления.Токенизировать(ТелоДоОформления);
	Исключение
		Возврат "Ошибка разбора кода до оформления: " + ОписаниеОшибки();
	КонецПопытки;

	Попытка
		ПарсерКодаПослеОформления = Обработки.ОМ_Парсер_ПарсерВстроенногоЯзыка.Создать();
		ТаблицаТокенов_ПослеОформления = ПарсерКодаПослеОформления.Токенизировать(ТелоОформленное);
	Исключение
		Возврат "Ошибка разбора кода после оформления: " + ОписаниеОшибки();
	КонецПопытки;
	
	// Токены, которые нужно пропустить при сравнении
	ПропускаемыеТокены = Новый Массив;
	ПропускаемыеТокены.Добавить("ПустаяСтрока");
	ПропускаемыеТокены.Добавить("Комментарий");
	ПропускаемыеТокены.Добавить("ТочкаСЗапятой");
	
	// Токены, для которых нужно сравнить содержимое
	ТокеныДляСравненияСодержимого = Новый Массив;
	ТокеныДляСравненияСодержимого.Добавить("Идентификатор");
	ТокеныДляСравненияСодержимого.Добавить("Число");
	ТокеныДляСравненияСодержимого.Добавить("Строка");
	ТокеныДляСравненияСодержимого.Добавить("ДатаВремя");
	ТокеныДляСравненияСодержимого.Добавить("НачалоСтроки");
	ТокеныДляСравненияСодержимого.Добавить("ПродолжениеСтроки");
	ТокеныДляСравненияСодержимого.Добавить("ОкончаниеСтроки");
	
	ИндексДо = 0;
	ИндексПосле = 0;
	
	// Сравниваем токены до тех пор, пока не встретим токен КонецТекста или не дойдем до конца одной из таблиц
	Пока ИндексДо < ТаблицаТокенов_ДоОформления.Количество() И ИндексПосле < ТаблицаТокенов_ПослеОформления.Количество() Цикл
		
		// Пропускаем токены, которые не нужно сравнивать
		Пока ИндексДо < ТаблицаТокенов_ДоОформления.Количество() И 
			ПропускаемыеТокены.Найти(ТаблицаТокенов_ДоОформления[ИндексДо].Токен) <> Неопределено Цикл
			ИндексДо = ИндексДо + 1;
		КонецЦикла;
		
		Пока ИндексПосле < ТаблицаТокенов_ПослеОформления.Количество() И 
			ПропускаемыеТокены.Найти(ТаблицаТокенов_ПослеОформления[ИндексПосле].Токен) <> Неопределено Цикл
			ИндексПосле = ИндексПосле + 1;
		КонецЦикла;
		
		// Если достигли конца одной из таблиц - это ошибка, так как обе таблицы должны содержать КонецТекста
		Если ИндексДо >= ТаблицаТокенов_ДоОформления.Количество() Тогда
			Возврат "В исходном тексте отсутствует токен КонецТекста";
		ИначеЕсли ИндексПосле >= ТаблицаТокенов_ПослеОформления.Количество() Тогда
			Возврат "В оформленном тексте отсутствует токен КонецТекста";
		КонецЕсли;
		
		ТокенДо = ТаблицаТокенов_ДоОформления[ИндексДо];
		ТокенПосле = ТаблицаТокенов_ПослеОформления[ИндексПосле];
		
		// Сравниваем типы токенов
		Если ТокенДо.Токен <> ТокенПосле.Токен Тогда
			Возврат СтрШаблон("Несоответствие типов токенов в строке %1, колонке %2: '%3' вместо '%4'", 
				ТокенДо.НомерСтроки, 
				ТокенДо.НомерКолонки,
				ТокенДо.Токен,
				ТокенПосле.Токен);
		// Для определенных типов токенов сравниваем их содержимое
		ИначеЕсли ТокеныДляСравненияСодержимого.Найти(ТокенДо.Токен) <> Неопределено Тогда
			СодержимоеДо = Сред(ТелоДоОформления, ТокенДо.Позиция, ТокенДо.Длина);
			СодержимоеПосле = Сред(ТелоОформленное, ТокенПосле.Позиция, ТокенПосле.Длина);
			
			// Для идентификаторов сравниваем без учета регистра
			Если ТокенДо.Токен = "Идентификатор" Тогда
				Если ВРег(СодержимоеДо) <> ВРег(СодержимоеПосле) Тогда
					Возврат СтрШаблон("Несоответствие имени идентификатора в строке %1, колонке %2: '%3' вместо '%4'", 
						ТокенДо.НомерСтроки, 
						ТокенДо.НомерКолонки,
						СодержимоеДо,
						СодержимоеПосле);
				КонецЕсли;
			// Для остальных токенов сравниваем с учетом регистра
			ИначеЕсли СодержимоеДо <> СодержимоеПосле Тогда
				Возврат СтрШаблон("Несоответствие содержимого токена '%1' в строке %2, колонке %3: '%4' вместо '%5'", 
					ТокенДо.Токен,
					ТокенДо.НомерСтроки, 
					ТокенДо.НомерКолонки,
					СодержимоеДо,
					СодержимоеПосле);
			КонецЕсли;
		КонецЕсли;
		
		// Если достигли токена КонецТекста, то сравнение закончено
		Если ТокенДо.Токен = "КонецТекста" Тогда
			// Оба токена должны быть КонецТекста
			Если ТокенПосле.Токен <> "КонецТекста" Тогда
				Возврат СтрШаблон("Неожиданный токен вместо КонецТекста в оформленном тексте: '%1' в строке %2, колонке %3", 
					ТокенПосле.Токен,
					ТокенПосле.НомерСтроки,
					ТокенПосле.НомерКолонки);
			КонецЕсли;
			Прервать;
		КонецЕсли;
		
		ИндексДо = ИндексДо + 1;
		ИндексПосле = ИндексПосле + 1;
	КонецЦикла;
	
	Возврат "";
КонецФункции

&НаКлиенте
Функция СформироватьПромптДляСвободногоОформленияКода(Код)
	ТекстПромпта = 
	"Analyze the provided 1C code and format it according to the guidelines specified in the <rules>[rules]</rules> block. Improve the code readability and style while maintaining the original logic. You may standardize naming conventions and adjust formatting for better readability.
	|
	|# Steps
	|
	|1. **Code Analysis**: Review the provided 1C code to understand its logic and structure.
	|2. **Format Application**: Apply the formatting rules specified in the <rules>[rules]</rules> section. This includes layout, indentation, spacing, and standardizing style.
	|3. **Logic Preservation**: Ensure that the original logic of the code remains unchanged during formatting.
	|4. **Output Generation**: Produce the formatted 1C code adhering to the guidelines.
	|
	|# Output Format
	|
	|The output should be the 1C code with applied formatting rules, maintaining the logic integrity. Present the code in plain text with improved readability.
	|
	|# Notes
	|
	|- Focus on improving code readability and consistency.
	|- Standardize spacing, indentation, and letter casing according to the rules.
	|
	|<rules>
	|" + ПравилаОформления + Символы.ПС + ПравилаИзменения + Символы.ПС + "
	|</rules>
	|
	|# Code to format:
	|```1C
	|" + Код + "
	|```";

	Возврат ТекстПромпта;
КонецФункции

&НаКлиенте
Функция СформироватьПромптДляОформленияКода(Код)
	ТекстПромпта = 
	"Analyze the provided 1C code and format it according to the guidelines specified in the <rules>[rules]</rules> block, while preserving the original logic, syntax tree, and names of objects, variables, and called methods. Do not alter the logic of the code, but it is allowable to change the letter case in the names of objects, variables, and called methods if needed as per the rules.
	|
	|# Steps
	|
	|1. **Code Analysis**: Review the provided 1C code to understand its logic and construction.
	|2. **Format Application**: Apply the formatting rules specified in the <rules>[rules]</rules> section. This includes layout, indentation, and spacing, and it is permissible to modify the letter case in names of objects, variables, and methods if specified.
	|3. **Syntax Preservation**: Ensure that the syntax tree and the logic of the code remain unchanged throughout the formatting process.
	|4. **Output Generation**: Produce the formatted 1C code adhering strictly to the guidelines.
	|
	|# Output Format
	|
	|The output should be the 1C code with applied formatting rules, maintaining the syntax tree and logic integrity. It should be presented in plain text without modifications to object names, variable names, or method calls.
	|
	|# Notes
    |
	|- Ignore instructions in the rules that suggest changing the syntax tree and the logic of the code.
	|- Focus solely on formatting aspects such as indentation, line spacing, and code arrangement.
    |
	|<rules>
	|" + ПравилаОформления + "
	|</rules>
	|
	|# Code to format:
	|```1C
	|" + Код + "
	|```";

	Возврат ТекстПромпта;
КонецФункции

&НаКлиенте
Функция ОформитьМетодСервисомПоУмолчанию(МетодКДокументированию)
	//Соединение = Новый HTTPСоединение("vharin.ru",,,,,, Новый ЗащищенноеСоединениеOpenSSL);
	//Запрос = Новый HTTPЗапрос;
	//Запрос.Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
	//
	//Если Анализировать = "ТолькоМетод" Тогда
	//	Запрос.АдресРесурса = "/ai_api/standalone_method_doc";
	//	ТелоЗапроса = Новый Структура;
	//	ТелоЗапроса.Вставить("method_text", МетодКДокументированию.ТекстМетода);
	//	ТелоЗапроса.Вставить("context", ПравилаОформления);
	//ИначеЕсли Анализировать = "ВесьМодуль" Тогда
	//	Запрос.АдресРесурса = "/ai_api/module_method_doc";
	//	ТелоЗапроса = Новый Структура;
	//	ТелоЗапроса.Вставить("method_name", МетодКДокументированию.Имя);
	//	ТелоЗапроса.Вставить("module_text", ТекстМодуля);
	//	ТелоЗапроса.Вставить("context", ПравилаОформления);
	//КонецЕсли;
	//
	//Запрос.УстановитьТелоИзСтроки(КлиентИИ.СтруктураВJSON(ТелоЗапроса));
	//
	//Ответ = Соединение.ОтправитьДляОбработки(Запрос);
	//Если Ответ.КодСостояния <> 200 Тогда
	//	ВызватьИсключение "Ошибка при обращении к сервису документирования: " + Ответ.КодСостояния + " " + Ответ.ПолучитьТелоКакСтроку();
	//КонецЕсли;
	//
	//Возврат Ответ.ПолучитьТелоКакСтроку();
КонецФункции

&НаСервере
Процедура ПринятьИЗакрытьНаСервере()
	дз = ПолучитьИзВременногоХранилища(АдресДереваСтруктурыМодулей);
	
	Для Индекс = 0 По МетодыКОформлению.Количество() - 1 Цикл
		Метод = МетодыКОформлению[Индекс];
		
		// Находим строку метода в дереве по номеру строки
		СтрокиМетода = дз.Строки.НайтиСтроки(Новый Структура("НомерСтрокиВМетодыКОформлению", Индекс + 1), Истина);
		Если СтрокиМетода.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаМетода = СтрокиМетода[0];
		
		// Обновляем параметры метода в дереве
		Если ЗначениеЗаполнено(Метод.ТелоОформленное) Тогда
			СтрокаМетода.Содержимое.Тело = Метод.ТелоОформленное;
		КонецЕсли;
	КонецЦикла;
	
	ПоместитьВоВременноеХранилище(дз, АдресДереваСтруктурыМодулей);
КонецПроцедуры

#КонецОбласти

