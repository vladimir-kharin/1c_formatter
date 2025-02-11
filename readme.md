﻿# Оформлятор модулей 1С

**Оформлятор модулей 1С** — расширяемый форматтер структуры модулей 1С. Он позволяет:
- Форматировать код, расставлять области (можно расширять форматтер под ваши регламенты, стандарты 1С и т.д.).
- Документировать методы при помощи LLM (вам остается проверить, поправить при необходимости).
- Анализировать код (в том числе строить граф вызовов, находить используемые поля и пр.).
- Перетаскивать функционал из других конфигураций, переводить язык синтаксиса и решать иные «точечные» задачи автоматизации. Но для этого нужно разрабатывать свои дополнительные компоненты (под ваши конерктные задачи).

Проект реализован целиком на языке 1С, поэтому любой разработчик 1С может изучить и доработать его под свои нужды без необходимости в освоении дополнительных стеков.

![Инфостарт]([./images/demo.gif](https://infostart.ru/bitrix/templates/sandbox_empty/assets/tpl/abo/img/logo.svg)) [Публикация на Инфостарт](https://infostart.ru/1c/tools/2297756/)

## Возможности
Что есть уже сейчас:

- **Расстановка стандартных областей** в модуле и автоматическое распределение по ним методов.
- **Документирование методов** с использованием LLM (есть режим где не нужен ключ API, но ограниченный - не более 15 тыс. символов в одном запросе и ограничения по количеству запросов в минуту).
- **Формирование текста модуля** на основании структуры данных (дерева) модуля.
- **Парсинг кода** в структуры нескольких уровней абстракции:
  - Токенизация.
  - Построение абстрактного синтаксического дерева (АСД).
  - Формирование структуры модуля (области, переменные, сигнатуры методов с информацией из документации в комментарии над методом). Это основное представление для дальнейших операций.
  - Анализ связей в коде (например, вызовы методов, используемые поля и т.д.).

## Типовой сценарий использования
Наиболее распространённый процесс «оформления» модуля выглядит так:

1. **Копирование модуля** из Конфигуратора 1С: открыть нужный модуль, <kbd>Ctrl + A</kbd>, затем <kbd>Ctrl + C</kbd>.
2. **Разбор модуля** в «Оформляторе»:
   - В инструменте выбрать «Добавить модуль» → «Из текста».
   - Вставить скопированный текст (<kbd>Ctrl + V</kbd>).
   - Нажать «Разобрать».
3. **Расстановка областей**: меню «Действия» → «Расстановка областей».
4. **Генерация документации** для методов (если требуется):
   - Клик правой кнопкой на области «ПрограммныйИнтерфейс» → «Документирование (с настройкой)...» → «Генерировать описание».
   - Проверить описание, при необходимости внести правки и сохранить.
5. **Формирование итогового текста модуля**: «Действия» → «Сформировать тексты модулей...».
6. **Копирование результата** обратно в Конфигуратор.

[Видеодемонстрация](https://vk.com/video-219359576_456239020), где в частности рассматривается внутреннее устройство и добавление компонент к решению.

![Demo GIF](./images/demo.gif)

## Структура репозитория и установка
- **[build/](https://github.com/vladimir-kharin/1c_formatter/tree/main/build)** — содержит готовый файл расширения (.cfe).  
  Скачайте этот файл и подключите его в свою конфигурацию 1С (начиная с платформы **8.3.14** и выше).
- **[src/](https://github.com/vladimir-kharin/1c_formatter/tree/main/src)** — содержит исходники в формате XML (выгрузка 1С).

Если вам достаточно пользоваться готовым функционалом, просто используйте .cfe из папки `build`.

## Архитектура и принцип работы
Основные модули и компоненты «Оформлятора»:
- **ОМ_Парсер_*** — обработки для токенизации и разбора модуля в АСД.  
  Основаны на проекте [bsparser](https://github.com/lead-tools/bsparser) (автор, если не ошибаюсь: [tsukanov-as](https://github.com/tsukanov-as)).   
  В [моём форке](https://github.com/vladimir-kharin/bsparser) добавлена поддержка современных конструкций встроенного языка 1С, таких как Асинх, Ждать и др.

- **ОМ_ОформляторМодулей** — основная интерфейсная форма, к которой подключаются остальные обработки. В модуле менеджера находится программный интерфейс для разбора, анализа и формирования структур данных модуля.

- **ОМ_Компонент_*** — вспомогательные компоненты, вызываемые из основной формы. Реализуют логику расстановки областей, формирования итогового текста, документирования методов и другие функции.

## Совместимость
- Минимальная версия платформы 1С: **8.3.14**.

## Как внести вклад (Contributing)
Проект открыт для вкладов сообщества. Будем рады вашим идеям и исправлениям:
1. Ознакомьтесь с [CONTRIBUTING.md](CONTRIBUTING.md).
2. Создайте Issue в GitHub с предложением или проблемой.
3. Оформляйте Pull Request с доработками — мы обязательно посмотрим и обсудим.

Если у вас возникли вопросы или предложения, смело пишите в [GitHub Issues](../../issues).

## Контакты
- **Email**: [vladimir.v.harin@gmail.com](mailto:vladimir.v.harin@gmail.com)
- **Telegram**: [@vladimir_kharin](https://t.me/vladimir_kharin)
- **Канал автора**: [https://t.me/prosto_pro1c](https://t.me/prosto_pro1c)

## Лицензия
Проект распространяется по лицензии **MIT**. Подробности см. в файле [LICENSE](LICENSE).
