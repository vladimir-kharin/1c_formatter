﻿#Область ПрограммныйИнтерфейс

// Преобразует строку в формате JSON в структуру.
// 
// Параметры:
//  СтрокаJSON - Строка - строка в формате JSON.
// 
// Возвращаемое значение:
//  Структура -
&НаКлиенте
Функция JSONВСтруктуру(СтрокаJSON) Экспорт
	// Выделяем в строке JSON часть именно JSON	
	// Находим позицию первого открывающего фигурного скобки
	ПозицияНачала = СтрНайти(СтрокаJSON, "{");
	Если ПозицияНачала = 0 Тогда
		// Если не найдено, возвращаем Неопределено или можно вызвать ошибку
		Возврат Неопределено;
	КонецЕсли;
	
	// Находим позицию последнего закрывающего фигурного скобки, используя поиск с конца
	ПозицияКонца = СтрНайти(СтрокаJSON, "}", НаправлениеПоиска.СКонца);
	Если ПозицияКонца = 0 Тогда
		// Если закрывающая скобка не найдена, возвращаем Неопределено
		Возврат Неопределено;
	КонецЕсли;
	
	// Вычисляем длину фрагмента с JSON: от первого "{" до последнего "}" включительно
	ДлинаФрагмента = ПозицияКонца - ПозицияНачала + 1;
	
	// Извлекаем корректную часть JSON из строки
	ЧистыйJSON = Сред(СтрокаJSON, ПозицияНачала, ДлинаФрагмента);
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(ЧистыйJSON);
	
	Результат = ПрочитатьJSON(ЧтениеJSON);
	
	ЧтениеJSON.Закрыть();
	
	Возврат Результат;
КонецФункции

// Отправляет запрос к OpenAI и возвращает ответ
// 
// Параметры:
//  Текст        - Строка - Содержимое сообщения
//  КлючAPI      - Строка - Ключ API для аутентификации
//  БазовыйАдрес - Строка - URL-адрес API, опционально
//  Модель       - Строка - Название модели, опционально
// 
// Возвращаемое значение:
//  Строка - Ответ от OpenAI или пустая строка
&НаКлиенте
Функция ОтправитьЗапросOpenAI(Текст, КлючAPI, БазовыйАдрес = Неопределено, Модель = Неопределено) Экспорт
	// Проверка наличия ключа API
	    Если ПустаяСтрока(КлючAPI) Тогда
	        ВызватьИсключение "Не указан ключ API";
	    КонецЕсли;
	    
	    ТекБазовыйАдрес = ?(ЗначениеЗаполнено(БазовыйАдрес), БазовыйАдрес, "https://openrouter.ai/api/v1/chat/completions");
	    ТекМодель = ?(ЗначениеЗаполнено(Модель), Модель, "openai/chatgpt-4o-latest");
	    
	    // Разбор базового адреса
	    РазобранныйURL = РазобратьURL(ТекБазовыйАдрес);
	    
	    // Подготовка HTTP-запроса
	    HTTPСоединение = Новый HTTPСоединение(
	        РазобранныйURL.Хост, 
	        РазобранныйURL.Порт, 
	        , 
	        , 
	        , 
	        120, 
	        ?(РазобранныйURL.Схема = "https", Новый ЗащищенноеСоединениеOpenSSL, Неопределено));
	    HTTPЗапрос = Новый HTTPЗапрос(РазобранныйURL.Путь);
	    HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
	    HTTPЗапрос.Заголовки.Вставить("Authorization", "Bearer " + КлючAPI);
	    
	    // Формирование тела запроса
	    СтруктураЗапроса = Новый Структура;
	    СтруктураЗапроса.Вставить("model", ТекМодель);
	    СтруктураЗапроса.Вставить("messages", Новый Массив);
	    СтруктураЗапроса.messages.Добавить(Новый Структура("role,content", "user", Текст));
	    
	    HTTPЗапрос.УстановитьТелоИзСтроки(СтруктураВJSON(СтруктураЗапроса));
	    
	    // Отправка запроса
	    Попытка
	        HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
	    Исключение
	        ВызватьИсключение "Ошибка отправки запроса: " + ОписаниеОшибки();
	    КонецПопытки;
	    
	    // Обработка ответа
	ТелоОтвета = HTTPОтвет.ПолучитьТелоКакСтроку();
	    Если HTTPОтвет.КодСостояния <> 200 Тогда
	        ВызватьИсключение СтрШаблон(
	        "Ошибка API. Код: %1, Ответ: %2", 
	        HTTPОтвет.КодСостояния, 
	        ТелоОтвета
	        );
	    КонецЕсли;
	    
	    // Разбор JSON-ответа
	    ОтветJSON = JSONВСтруктуру(ТелоОтвета);
	    
	    // Проверка на наличие ошибки в ответе
	    Если ОтветJSON.Свойство("error") Тогда
	        ВызватьИсключение СтрШаблон(
	        "Ошибка API. Код: %1, Сообщение: %2", 
	        ОтветJSON.error.code, 
	        ТелоОтвета
	        );
	    КонецЕсли;
	    
	    Если ОтветJSON.choices.Количество() > 0 Тогда
	        Возврат ОтветJSON.choices[0].message.content;
	    Иначе
	        Возврат "";
	    КонецЕсли;
КонецФункции

// Разбирает URL на составляющие: схема, хост, порт и путь
// 
// Параметры:
//  URL - Строка - URL для разбора
// 
// Возвращаемое значение:
//  Структура - Разобранные части URL (схема, хост, порт, путь)
&НаКлиенте
Функция РазобратьURL(Знач URL) Экспорт
	РезультатРазбора = Новый Структура("Схема, Хост, Порт, Путь");
	    
	    // Проверка и удаление протокола
	    Если НРег(Лев(URL, 8)) = "https://" Тогда
	        РезультатРазбора.Схема = "https";
	        URL = Сред(URL, 9);
	    ИначеЕсли НРег(Лев(URL, 7)) = "http://" Тогда
	        РезультатРазбора.Схема = "http";
	        URL = Сред(URL, 8);
	    Иначе
	        ВызватьИсключение "Неверный формат URL: отсутствует протокол http или https";
	    КонецЕсли;
	    
	    // Разделение хоста, порта и пути
	    ПозицияСлеш = СтрНайти(URL, "/");
	    Если ПозицияСлеш > 0 Тогда
	        ХостИПорт = Лев(URL, ПозицияСлеш - 1);
	        РезультатРазбора.Путь = Сред(URL, ПозицияСлеш);
	    Иначе
	        ХостИПорт = URL;
	        РезультатРазбора.Путь = "/";
	    КонецЕсли;
	    
	    // Разделение хоста и порта
	    ПозицияДвоеточие = СтрНайти(ХостИПорт, ":");
	    Если ПозицияДвоеточие > 0 Тогда
	        РезультатРазбора.Хост = Лев(ХостИПорт, ПозицияДвоеточие - 1);
	        РезультатРазбора.Порт = Число(Сред(ХостИПорт, ПозицияДвоеточие + 1));
	    Иначе
	        РезультатРазбора.Хост = ХостИПорт;
	        РезультатРазбора.Порт = ?(РезультатРазбора.Схема = "https", 443, 80);
	    КонецЕсли;
	    
	    Возврат РезультатРазбора;
КонецФункции

// Преобразует структура в строку JSON
// 
// Параметры:
//  Объект - Структура - которую необходимо преобразовать в строку JSON.
// 
// Возвращаемое значение:
//  Строка - в формате JSON.
&НаКлиенте
Функция СтруктураВJSON(Объект) Экспорт
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Объект);
	
	Возврат ЗаписьJSON.Закрыть();
КонецФункции

#КонецОбласти

