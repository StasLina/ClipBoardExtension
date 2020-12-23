﻿&НаСервере
Перем ТекущаяГруппа, ТекущаяСтрока, ПроверяемоеЗначение, ЕстьПроблема, ЕстьОшибка;

&НаСервере
Перем HTTPСоединение, ТекущийКаталог, ИмяФайлаОбработки, ЕстьОшибкиПроблемы;

#Область СобытияФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("Автотестирование", Автотестирование);
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ФайлОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	ИмяФайлаОбработки = ФайлОбработки.Имя;
	ТекущийКаталог = ФайлОбработки.Путь;
	
	Если Автотестирование Тогда
		Попытка
			СоздатьСоединение();
			ВыполнитьТесты();
		Исключение
			Лог = Новый ЗаписьТекста(ТекущийКаталог + "autotest.log");
			Лог.ЗаписатьСтроку(ИнформацияОбОшибке().Описание);
			Лог.Закрыть();
		КонецПопытки;
	Иначе
		ВыполнитьТесты();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Автотестирование Тогда
		ПодключитьОбработчикОжидания("ЗавершитьРаботу", 1, Истина);
	Иначе
		Для каждого ЭлементСписка из СписокУзлов Цикл
			Элементы.Результаты.Развернуть(ЭлементСписка.Значение, Истина);
		КонецЦикла;
		СписокУзлов.Очистить();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьРаботу()
	
	ЗавершитьРаботуСистемы(Ложь);
	
КонецПроцедуры

#КонецОбласти

#Область МетодыAppVeyor

&НаСервере
Процедура СоздатьСоединение()
	
	ЧтениеТекста = Новый ЧтениеТекста(ТекущийКаталог + "app_port.txt");
	Порт = Число(ЧтениеТекста.Прочитать());
	HTTPСоединение = Новый HTTPСоединение("localhost", Порт);
	
КонецПроцедуры

&НаСервере
Процедура ОтправитьСообщение(Сообщение, Статус, ПОдробно = "")
	
	Структура = Новый Структура;
	Структура.Вставить("message", Строка(Сообщение));
	Структура.Вставить("category", Строка(Статус));
	Структура.Вставить("details", Строка(ПОдробно));
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Структура);
	ТекстJSON = ЗаписьJSON.Закрыть();
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/build/messages");
	HTTPЗапрос.УстановитьТелоИзСтроки(ТекстJSON);
	HTTPЗапрос.Заголовки.Вставить("Content-type", "application/json");
	HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
	
КонецПроцедуры

&НаСервере
Процедура ОтправитьТест(ИмяТеста, Длительность, Статус, Подробно = "")
	
	Структура = Новый Структура;
	Структура.Вставить("outcome", Статус);
	Структура.Вставить("testName", ИмяТеста);
	Структура.Вставить("fileName", ИмяФайлаОбработки);
	Структура.Вставить("ErrorMessage", Подробно);
	Структура.Вставить("durationMilliseconds", Длительность);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Структура);
	ТекстJSON = ЗаписьJSON.Закрыть();
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/tests");
	HTTPЗапрос.УстановитьТелоИзСтроки(ТекстJSON);
	HTTPЗапрос.Заголовки.Вставить("Content-type", "application/json");
	HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
	
КонецПроцедуры

#КонецОбласти

#Область ЭкспортныеМетоды

&НаСервере
Функция Тест(Знач Представление = "") Экспорт
	
	ТекущаяСтрока = ТекущаяГруппа.ПолучитьЭлементы().Добавить();
	ТекущаяСтрока.Наименование = Представление;
	ТекущаяСтрока.КартинкаСтрок = 1;
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция Что(Знач Значение) Экспорт
	
	ПроверяемоеЗначение = Значение;
	ТекущаяСтрока.Результат = Значение;
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция Значение() Экспорт
	
	Возврат ПроверяемоеЗначение;
	
КонецФункции	

&НаСервере
Функция ЗначениеJSON() Экспорт
	
	Если ПустаяСтрока(ПроверяемоеЗначение) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ПоляДаты = Новый Массив;
	ПоляДаты.Добавить("CreationDate");
	ПоляДаты.Добавить("date");
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(ПроверяемоеЗначение);
	Возврат ПрочитатьJSON(ЧтениеJSON, , ПоляДаты);
	
КонецФункции

&НаСервере
Функция Получить(Знач Имя) Экспорт
	
	Если ПустаяСтрока(ТекущаяСтрока.Наименование) Тогда
		ТекущаяСтрока.Наименование = "Получить свойство: " + Имя;
	КонецЕсли;
	
	ПроверяемоеЗначение = ПроверяемоеЗначение[Имя];
	ТекущаяСтрока.Результат = ПроверяемоеЗначение;
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция Установить(Знач Имя, Знач Значение) Экспорт
	
	Если ПустаяСтрока(ТекущаяСтрока.Наименование) Тогда
		ТекущаяСтрока.Наименование = "Установить свойство: " + Имя;
	КонецЕсли;
	
	ТекущаяСтрока.Результат = Значение;
	ПроверяемоеЗначение[Имя] = Значение;
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция ПолучитьФормулу(Знач Имя, Знач П1 = "ПУСТО", Знач П2 = "ПУСТО", Знач П3 = "ПУСТО", Знач П4 = "ПУСТО", Знач П5 = "ПУСТО", Знач П6 = "ПУСТО", Знач П7 = "ПУСТО")
	
	Формула = "";
	Количество = 7;
	Для Номер = 0 по Количество - 1 Цикл
		ИмяПараметра = "П" + (Количество - Номер);
		Если Не ПустаяСтрока(Формула) Тогда
			Формула = "," + Формула;
		КонецЕсли;
		Если Вычислить(ИмяПараметра) <> "ПУСТО" Тогда
			Формула = ИмяПараметра + Формула;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "ПроверяемоеЗначение." + Имя + "(" + Формула + ")";
	
КонецФункции	

&НаСервере
Функция Функц(Знач Имя, Знач П1 = "ПУСТО", Знач П2 = "ПУСТО", Знач П3 = "ПУСТО", Знач П4 = "ПУСТО", Знач П5 = "ПУСТО", Знач П6 = "ПУСТО", Знач П7 = "ПУСТО") Экспорт
	
	Если ПустаяСтрока(ТекущаяСтрока.Наименование) Тогда
		ТекущаяСтрока.Наименование = "Функция: " + Имя;
	КонецЕсли;
	
	Формула = ПолучитьФормулу(Имя, П1, П2, П3, П4, П5, П6, П7);
	ПроверяемоеЗначение = Вычислить(Формула);
	ТекущаяСтрока.Результат = ПроверяемоеЗначение;
	
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция Проц(Знач Имя, Знач П1 = "ПУСТО", Знач П2 = "ПУСТО", Знач П3 = "ПУСТО", Знач П4 = "ПУСТО", Знач П5 = "ПУСТО", Знач П6 = "ПУСТО", Знач П7 = "ПУСТО") Экспорт
	
	Если ПустаяСтрока(ТекущаяСтрока.Наименование) Тогда
		ТекущаяСтрока.Наименование = "Процедура: " + Имя;
	КонецЕсли;
	
	Формула = ПолучитьФормулу(Имя, П1, П2, П3, П4, П5, П6, П7);
	Выполнить(Формула);
	
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция Равно(Знач Значение) Экспорт
	
	ТекущаяСтрока.Эталон = Строка(Значение);
	Если ПроверяемоеЗначение <> Значение Тогда
		ЗаписатьПроблему("Проверяемое значение не соответствует эталону");
	КонецЕсли;
	
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция ЕстьИстина() Экспорт
	
	ТекущаяСтрока.Эталон = "Значение = Истина";
	Если ПроверяемоеЗначение <> Истина Тогда
		ЗаписатьПроблему("Проверяемое значение есть ложь");
	КонецЕсли;
	
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция ИмеетТип(Знач ТипИлиИмяТипа) Экспорт
	
	ОжидаемыйТип = ?(ТипЗнч(ТипИлиИмяТипа) = Тип("Строка"), Тип(ТипИлиИмяТипа), ТипИлиИмяТипа);
	ТекущаяСтрока.Эталон = "ТипЗнч(Значение) = Тип(""" + Строка(ТипИлиИмяТипа) + """)";
	ТипПроверяемогоЗначения = ТипЗнч(ПроверяемоеЗначение);
	Если ТипПроверяемогоЗначения <> ОжидаемыйТип Тогда
		Результат = "Неверный тип значения: " + ПроверяемоеЗначение;
		ЗаписатьПроблему(Результат);
	КонецЕсли;
	
	Возврат ЭтаФорма;
	
КонецФункции

&НаСервере
Функция Больше(Знач МеньшееЗначение) Экспорт
	
	ТекущаяСтрока.Эталон = "Значение > " + Строка(МеньшееЗначение);
	
	Если Не (ПроверяемоеЗначение > МеньшееЗначение) Тогда
		ЗаписатьПроблему("Проверяемое значение должно быть больше ");
	КонецЕсли;
	
	Возврат ЭтотОбъект;
	
КонецФункции

&НаСервере
Функция ЭтоКартинка(Знач Формат = Неопределено) Экспорт
	
	Если Формат = Неопределено Тогда
		Формат = ФорматКартинки.PNG;
	КонецЕсли;
	
	ПроверяемаяКартинка = Новый Картинка(ПроверяемоеЗначение);
	Если ПроверяемаяКартинка.Формат() <> ФорматКартинки.PNG Тогда
		ЗаписатьПроблему("Формат картинки не соответствует ожидаемому: " + ФорматКартинки.PNG);
	КонецЕсли;
	
	Возврат ЭтаФорма;
	
КонецФункции	

&НаСервере
Функция ДобавитьПроверку(Результат, Эталон = Неопределено, Представление = "")
	
	ТекущаяСтрока = ТекущаяГруппа.ПолучитьЭлементы().Добавить();
	ТекущаяСтрока.Наименование = Представление;
	ТекущаяСтрока.КартинкаСтрок = 1;
	ТекущаяСтрока.Результат = Результат;
	ТекущаяСтрока.Эталон = Эталон;
	Возврат ТекущаяСтрока;
	
КонецФункции

&НаСервере
Процедура ЗаписатьПроблему(ТекстПроблемы = "")

	ЕстьПроблема = Истина;
	ЕстьОшибкиПроблемы = Истина; 
	
	Если ТекущаяСтрока = Неопределено Тогда
		ТекущаяСтрока = ТекущаяГруппа.ПолучитьЭлементы().Добавить();
		ТекущаяСтрока.Наименование = "Неизвестная проблема";
	КонецЕсли;
	
	ТекущаяСтрока.Подробности = ТекстПроблемы;
	ТекущаяСтрока.КартинкаСтрок = 2;
	ТекущаяГруппа.КартинкаСтрок = 2;
	
	Если Автотестирование Тогда
		ОтправитьСообщение(ТекущаяСтрока.Наименование, "Warning", ТекстПроблемы);
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьОшибку(Результат, Подробности)
	
	ЕстьОшибка = Истина;
	ЕстьОшибкиПроблемы = Истина; 
	
	Если ТекущаяСтрока = Неопределено Тогда
		ТекущаяСтрока = ТекущаяГруппа.ПолучитьЭлементы().Добавить();
		ТекущаяСтрока.Наименование = "Неизвестная ошибка";
	КонецЕсли;
	
	ТекущаяСтрока.Эталон = Результат;
	ТекущаяСтрока.Подробности = Подробности;
	ТекущаяСтрока.КартинкаСтрок = 3;
	ТекущаяГруппа.КартинкаСтрок = 3;
	
	Если Автотестирование Тогда
		ОтправитьСообщение(ТекущаяСтрока.Наименование, "Error", Подробности);
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьЗначение(Значение, Представление = "") Экспорт
	
	ТекущаяСтрока = ДобавитьПроверку(Значение, Неопределено, Представление);
	ТекущаяСтрока.Подробности = Значение;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьУсловие(Значение, Условие, Представление = "", ТекстУсловия = "") Экспорт
	
	ТекущаяСтрока = ДобавитьПроверку(Значение, Истина, Представление);
	Если Не ПустаяСтрока(ТекстУсловия) Тогда 
		ТекущаяСтрока.Эталон = ТекстУсловия;
	КонецЕсли;
		
	Если Не Условие Тогда
		ЗаписатьПроблему("Не выполнено условие проверки");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьРавенство(Значение, Эталон, Представление = "") Экспорт
	
	ТекущаяСтрока = ДобавитьПроверку(Значение, Эталон, Представление);
	Если Значение <> Эталон Тогда
		ЗаписатьПроблему("Значение не соответствует эталону");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьТип(Значение, ТипИлиИмяТипа, Представление = "") Экспорт
	
	ТекущаяСтрока = ДобавитьПроверку(Значение, ТипИлиИмяТипа, Представление);
	
	Если ТипЗнч(ТипИлиИмяТипа) = Тип("Строка") Тогда
		ОжидаемыйТип = Тип(ТипИлиИмяТипа);
	ИначеЕсли ТипЗнч(ТипИлиИмяТипа) = Тип("Тип") Тогда
		ОжидаемыйТип = ТипИлиИмяТипа;
	Иначе
		ЗаписатьПроблему("Неверный тип параметра");
		Возврат;
	КонецЕсли;
	
	ТекущаяСтрока.Эталон = ОжидаемыйТип;
	Если ТипЗнч(Значение) <> ОжидаемыйТип Тогда
		ЗаписатьПроблему("Неверный тип значения");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьТест(Знач ИмяМетода, Знач Параметры = Неопределено, Знач Представление = "") Экспорт
	
	Если Не ЗначениеЗаполнено(Параметры) ИЛИ ТипЗнч(Параметры) <> Тип("Массив") Тогда
		Если ТипЗнч(Параметры) = Тип("Строка") И Представление = "" Тогда
			Представление = Параметры;
		КонецЕсли;
		Параметры = Неопределено;
	КонецЕсли;
	
	ТекущаяСтрока = Результаты.ПолучитьЭлементы().Добавить();
	ТекущаяСтрока.Наименование = Представление;
	ТекущаяСтрока.ИмяМетода = ИмяМетода;
	
	СписокУзлов.Добавить(ТекущаяСтрока.ПолучитьИдентификатор());
	
КонецПроцедуры

#КонецОбласти

&НаСервере
Процедура ВыполнитьТест(ОбработкаОбъект)
	
	ЕстьОшибка = Ложь;
	ЕстьПроблема = Ложь;
	
	ТекущаяСтрока = Неопределено;
	
	Попытка
		ТекущаяГруппа.КартинкаСтрок = 1;
		ВремяСтарта = ТекущаяУниверсальнаяДатаВМиллисекундах();
		Выполнить("ОбработкаОбъект." + ТекущаяГруппа.ИмяМетода + "()");
	Исключение
		Информация = ИнформацияОбОшибке();
		Результат = КраткоеПредставлениеОшибки(Информация);
		Подробности = ПодробноеПредставлениеОшибки(Информация);
		ЗаписатьОшибку(Результат, Подробности);
	КонецПопытки;
	
	Если Автотестирование Тогда
		Статус = ?(ЕстьОшибка, "Failed", ?(ЕстьПроблема, "Inconclusive", "Passed"));
		Длительность = ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяСтарта;
		ОтправитьТест(ТекущаяГруппа.Наименование, Длительность, Статус);
	КонецЕсли;
	
КонецПроцедуры	
 
&НаСервере
Процедура ВыполнитьТесты()
	
	ЕстьОшибкиПроблемы = Ложь;
	
	Результаты.ПолучитьЭлементы().Очистить();
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ОбработкаОбъект.ЗаполнитьНаборТестов(ЭтаФорма);
	Для каждого ТекСтр из Результаты.ПолучитьЭлементы() Цикл
		ТекущаяГруппа = ТекСтр;
		ВыполнитьТест(ОбработкаОбъект);
	КонецЦикла;
	
	Если Автотестирование И НЕ ЕстьОшибкиПроблемы Тогда
		ЗаписьТекста = Новый ЗаписьТекста(ТекущийКаталог + "success.txt");
		ЗаписьТекста.ЗаписатьСтроку(ТекущаяУниверсальнаяДата());
		ЗаписьТекста.Закрыть();
	КонецЕсли;
	
КонецПроцедуры	


#Область СтарыеТесты

&НаСервере
Функция JSON(ТекстJSON)
	
	Если ПустаяСтрока(ТекстJSON) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ПоляДаты = Новый Массив;
	ПоляДаты.Добавить("CreationDate");
	ПоляДаты.Добавить("date");
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(ТекстJSON);
	Возврат ПрочитатьJSON(ЧтениеJSON, , ПоляДаты);
	
КонецФункции

&НаСервере
Функция ДобавитьГруппуТестов(Родитель, Наименование)
	
КонецФункции

&НаСервере
Процедура ЗаписатьГруппуТестов(ТекСтр)
	
КонецПроцедуры

&НаСервере
Функция ТестВычислить(Группа, ИмяТеста, Выражение, Эталон = "")
	
КонецФункции

&НаСервере
Процедура ТестВыполнить(Группа, ИмяТеста, Выражение, Эталон = "")
	
	
КонецПроцедуры

&НаСервере
Функция ПолучитьЛоготип1С()
	
	ФайлРесурса = "v8res://mngbase/About.lf";
	ВременныйФайл = ПолучитьИмяВременногоФайла();
	КопироватьФайл(ФайлРесурса, ВременныйФайл);
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.Прочитать(ВременныйФайл);
	УдалитьФайлы(ВременныйФайл);
	
	Стр = ТекстовыйДокумент.ПолучитьТекст();
	НачПоз = СтрНайти(Стр, "{#base64:");
	КонПоз = СтрНайти(Стр, "}", , НачПоз);
	Стр = Сред(Стр, НачПоз + 9, КонПоз - НачПоз - 9);
	ДвоичныеДанные = Base64Значение(Стр);
	
	Картинка = Новый Картинка(ДвоичныеДанные);
	Соответствие = Новый Соответствие;
	Соответствие.Вставить("screenDensity", "xdpi");
	Возврат Картинка.ПолучитьДвоичныеДанные(Ложь, Соответствие);
	
КонецФункции

&НаСервере
Функция ПрочитатьТекст(ДвоичныеДанные)
	
	Поток = ДвоичныеДанные.ОткрытьПотокДляЧтения();
	ЧтениеТекста = Новый ЧтениеТекста(Поток);
	Возврат СокрЛП(ЧтениеТекста.Прочитать());
	
КонецФункции	

&НаСервере
Функция ФайлСуществует(ИмяФайла)
	
	Файл = Новый Файл(ИмяФайла);
	Возврат Файл.Существует();
	
КонецФункции	

&НаСервере
Процедура СтарыеТесты()
		
	
	Группа = ДобавитьГруппуТестов(Результаты, "Свойства WindowsControl");
	ТестВычислить(Группа, "Получить: Version", "ВК.Version");
	ТестВычислить(Группа, "Получить: Версия", "ВК.Версия");
	ТестВычислить(Группа, "Получить: ВЕРСИЯ", "ВК.ВЕРСИЯ");
	PID = ТестВычислить(Группа, "Получить: ProcessId", "ВК.ProcessId", "Значение > 0");
	ТестВычислить(Группа, "ИдентификаторПроцесса", "ВК.ИдентификаторПроцесса", "Значение > 0");
	ТестВыполнить(Группа, "Установить: ТекстБуфераОбмена", "ВК.ТекстБуфераОбмена = ""ТекстБуфера""");
	ТестВычислить(Группа, "Получить: ТекстБуфераОбмена", "ВК.ТекстБуфераОбмена", "Значение = ""ТекстБуфера""");
	ТестВычислить(Группа, "Получить: ТекстБуфераОбмена", "ВК.ТекстБуфераОбмена", "Значение = ""ТекстБуфера""");
	ТестВыполнить(Группа, "Установить: КартинкаБуфераОбмена", "ВК.КартинкаБуфераОбмена = ПолучитьЛоготип1С()");
	ТестВычислить(Группа, "Получить: КартинкаБуфераОбмена", "ВК.КартинкаБуфераОбмена", "ТипЗнч(Значение) = Тип(""ДвоичныеДанные"")");
	ТестВычислить(Группа, "Получить: Формат картинки", "Новый Картинка(Значение)", "Значение.Формат() = ФорматКартинки.PNG");
	ТестВычислить(Группа, "Получить: СвойстваЭкрана", "ВК.СвойстваЭкрана");
	ТестВычислить(Группа, "Получить: СписокДисплеев", "ВК.СписокДисплеев");
	ТестВычислить(Группа, "Получить: СписокОкон", "ВК.СписокОкон");
	hWnd = ТестВычислить(Группа, "Получить: АктивноеОкно", "ВК.АктивноеОкно");
	ТестВычислить(Группа, "Получить: ПозицияКурсора", "ВК.ПозицияКурсора");
	ЗаписатьГруппуТестов(Группа);
	
	Группа = ДобавитьГруппуТестов(Результаты, "Методы WindowsControl");
	ТестВычислить(Группа, "НайтиКлиентТестирования(48000)", "ВК.НайтиКлиентТестирования(48000)");
	ТестВычислить(Группа, "ПолучитьСвойстваОкна(hWnd)", "ВК.ПолучитьСвойстваОкна(hWnd)", "JSON(Значение).ProcessId = ВК.ProcessId");
	ТестВычислить(Группа, "ПолучитьСписокПроцессов(Истина)", "ВК.ПолучитьСписокПроцессов(Истина)");
	ТестВычислить(Группа, "ПолучитьСвойстваПроцесса(PID)", "ВК.ПолучитьСвойстваПроцесса(PID)", "JSON(Значение).ProcessId = PID");
	ТестВычислить(Группа, "ПолучитьСписокДисплеев()", "ВК.ПолучитьСписокДисплеев()");
	ТестВычислить(Группа, "ПолучитьСписокДисплеев(hWnd)", "ВК.ПолучитьСписокДисплеев(hWnd)");
	ТестВычислить(Группа, "ПолучитьСвойстваДисплея(hWnd)", "ВК.ПолучитьСвойстваДисплея(hWnd)");
	ТестВычислить(Группа, "ПолучитьСписокОкон(PID)", "ВК.ПолучитьСписокОкон(PID)");
	ТестВычислить(Группа, "ПолучитьСвойстваОкна(hWnd)", "ВК.ПолучитьСвойстваОкна(hWnd)");
	ТестВычислить(Группа, "ПолучитьРазмерОкна(hWnd)", "ВК.ПолучитьРазмерОкна(hWnd)");
	Размеры = JSON(Группа);
	W = Формат(Размеры.Width - 1, "ЧГ=");
	H = Формат(Размеры.Height - 1, "ЧГ=");
	L = Формат(Размеры.Left + 1, "ЧГ=");
	T = Формат(Размеры.Top + 1, "ЧГ=");
	
	ТестВыполнить(Группа, "АктивироватьОкно(hWnd)", "ВК.АктивироватьОкно(hWnd)");
	ТестВыполнить(Группа, "РаспахнутьОкно(hWnd)", "ВК.РаспахнутьОкно(hWnd)");
	ТестВыполнить(Группа, "РазвернутьОкно(hWnd)", "ВК.РазвернутьОкно(hWnd)"); 
	ТестВыполнить(Группа, "СвернутьОкно(hWnd)", "ВК.СвернутьОкно(hWnd)");
	ТестВыполнить(Группа, "Пауза(100)", "ВК.Пауза(100)");
	ТестВыполнить(Группа, "РазвернутьОкно(hWnd)", "ВК.РазвернутьОкно(hWnd)"); 
	ТестВыполнить(Группа, "УстановитьРазмерОкна()", "ВК.УстановитьРазмерОкна(hWnd, " + W + ", " + H + ")");
	ТестВыполнить(Группа, "УстановитьПозициюОкна()", "ВК.УстановитьПозициюОкна(hWnd, " + L + ", " + T + ")");
	ЗаписатьГруппуТестов(Группа);
	
	Группа = ДобавитьГруппуТестов(Результаты, "Получение снимка экрана");
	ТестВычислить(Группа, "ПолучитьСнимокОбласти()", "ВК.ПолучитьСнимокОбласти(" + L + "," + T + "," + W + "," + H + ")");
	ТестВычислить(Группа, "ПолучитьСнимокЭкрана()", "ВК.ПолучитьСнимокЭкрана()");
	ТестВычислить(Группа, "ПолучитьСнимокЭкрана(2)", "ВК.ПолучитьСнимокЭкрана(2)");
	ТестВычислить(Группа, "ПолучитьСнимокЭкрана(1)", "ВК.ПолучитьСнимокЭкрана(1)");
	ТестВычислить(Группа, "ПолучитьСнимокЭкрана(0)", "ВК.ПолучитьСнимокЭкрана(0)");
	ТестВычислить(Группа, "НайтиФрагмент()", "ВК.НайтиФрагмент(Значение, ВК.ПолучитьСнимокОкна(hWnd))", "JSON(Значение).match > 0.7");
	ТестВычислить(Группа, "НайтиНаЭкране()", "ВК.НайтиНаЭкране(ВК.ПолучитьСнимокОкна(hWnd))", "JSON(Значение).match > 0.7");
	ТестВычислить(Группа, "ПолучитьСнимокОкна()", "ВК.ПолучитьСнимокОкна()");
	ЗаписатьГруппуТестов(Группа);
	
	ВыполнитьТестыGit();
	
КонецПроцедуры	
	
&НаСервере
Процедура ВыполнитьТестыGit()
	
	Группа = ДобавитьГруппуТестов(Результаты, "Тестирование GitFor1C");
	
	ИмяПапки = "Autotest";
	ВременнаяПапка = ПолучитьИмяВременногоФайла("git");
	УдалитьФайлы(ВременнаяПапка);
	СоздатьКаталог(ВременнаяПапка);
	Репозиторий = ВременнаяПапка + "/" + ИмяПапки + "/";
	Подкаталог = Репозиторий + "test";
	СоздатьКаталог(Репозиторий);
	СоздатьКаталог(Подкаталог);
	
	АдресКлон = "https://github.com/lintest/AddinTemplate.git";
	ПапкаКлон = ВременнаяПапка + "clone";
	ФайлКлон = ПапкаКлон + "/LICENSE";
	
	ИмяФайла = "example.txt";
	ПолноеИмя = Репозиторий + ИмяФайла;
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ДобавитьСтроку(ЧислоПрописью(51243, "L=en_US"));
	ТекстовыйДокумент.ДобавитьСтроку(ЧислоПрописью(24565, "L=en_US"));
	ТекстовыйДокумент.Записать(ПолноеИмя, КодировкаТекста.UTF8);
	
	ТестВыполнить(Группа, "Назначение автора", "git.SetAuthor(""Автор"", ""author@lintest.ru"")"); 
	ТестВыполнить(Группа, "Назначение комиттера", "git.SetCommitter(""Комиттер"", ""committer@lintest.ru"")"); 
	ТестВычислить(Группа, "Версия", "git.version");
	ТестВычислить(Группа, "Клонирование", "git.clone("""+ АдресКлон +  """, """ + ПапкаКлон + """)", "ФайлСуществует(""" + ФайлКлон + """)");
	ТестВычислить(Группа, "Информация о коммите", "git.info(""HEAD"")", "JSON(Значение).success");
	ТестВычислить(Группа, "Список репозиториев", "git.remotes", "JSON(Значение).result[0].name = ""origin"" И JSON(Значение).result[0].url = """ + АдресКлон + """");
	ТестВычислить(Группа, "Закрытие репозитория", "git.close()", "JSON(Значение).success");
	ТестВычислить(Группа, "Инициализация", "git.init(""" + Репозиторий + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Статус рабочей области", "git.status()", "JSON(Значение).result.work[0].new_name = ""example.txt""");
	ТестВычислить(Группа, "Добавление в индекс", "git.add(""" + ИмяФайла + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Статус индекса", "git.status()", "JSON(Значение).result.index[0].new_name = ""example.txt""");
	ТестВычислить(Группа, "Первый коммит", "git.commit(""Инициализация"")", "JSON(Значение).success");
	ТестВычислить(Группа, "Информация о коммите", "git.info(""HEAD"")", "JSON(Значение).result.authorName = ""Автор"" И JSON(Значение).result.committerName = ""Комиттер""");
	ТестВычислить(Группа, "Закрытие репозитория", "git.close()", "JSON(Значение).success");
	ТестВычислить(Группа, "Статус закрытого репозитория", "git.status()", "НЕ JSON(Значение).success И JSON(Значение).error.code = 0");
	
	ИмяФайла = "текст.txt";
	ПолноеИмя = Репозиторий + ИмяФайла;
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ДобавитьСтроку("Содержимое");
	ТекстовыйДокумент.Записать(ПолноеИмя, КодировкаТекста.UTF8);
	
	ТестВычислить(Группа, "Поиск репозитория", "git.find(""" + Подкаталог + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Открытие репозитория", "git.open(JSON(Значение).result)", "JSON(Значение).success");
	ТестВычислить(Группа, "Статус рабочей области", "git.status()", "JSON(Значение).result.work[0].new_name = ""текст.txt""");
	ТестВычислить(Группа, "Добавление в индекс", "git.add(""" + ИмяФайла + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Статус индекса", "git.status()", "JSON(Значение).result.index[0].new_name = ""текст.txt""");
	ТестВычислить(Группа, "Чтение BLOB из индекса", "git.blob(JSON(Значение).result.index[0].new_id)", "ПрочитатьТекст(Значение) = ""Содержимое""");
	ТестВычислить(Группа, "Второй коммит", "git.commit(""Второй коммит"")", "JSON(Значение).success");
	ТестВычислить(Группа, "История", "git.history()", "JSON(Значение).result.Количество() = 2 И JSON(Значение).result[0].message = ""Второй коммит""");
	ТестВычислить(Группа, "Создание новой ветки", "git.checkout(""develop"", Истина)", "JSON(Значение).success");
	ТестВычислить(Группа, "Список веток", "git.branches", "JSON(Значение).Количество() = 2");
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ДобавитьСтроку("Редактирование");
	ТекстовыйДокумент.Записать(ПолноеИмя, КодировкаТекста.UTF8);
	
	ТестВычислить(Группа, "Добавление в индекс", "git.add(""" + ИмяФайла + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Статус индекса", "git.status()", "JSON(Значение).result.index[0].new_name = ""текст.txt""");
	ТестВычислить(Группа, "Удаление из индекса", "git.reset(""" + ИмяФайла + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Статус индекса", "git.status()", "JSON(Значение).result.work[0].new_name = ""текст.txt""");
	ТестВычислить(Группа, "Отмена изменений", "git.discard(""" + ИмяФайла + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Нет изменений", "git.status()", "JSON(Значение).result = Неопределено");
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ДобавитьСтроку("Редактирование");
	ТекстовыйДокумент.Записать(ПолноеИмя, КодировкаТекста.UTF8);
	ТестВычислить(Группа, "Добавление в индекс", "git.add(""" + ИмяФайла + """)", "JSON(Значение).success");
	ТестВычислить(Группа, "Третий коммит", "git.commit(""Третий коммит"")", "JSON(Значение).success");
	ТестВычислить(Группа, "Указатель HEAD", "git.head", "JSON(Значение).result = ""refs/heads/develop""");
	ТестВычислить(Группа, "Переключение ветки", "git.checkout(""master"")", "JSON(git.head).result = ""refs/heads/master""");
	
	ЗаписатьГруппуТестов(Группа);
	
КонецПроцедуры

#КонецОбласти
