﻿&НаКлиенте
Перем ИдентификаторКомпоненты, ВнешняяКомпонента, БуферОбмена;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Автотестирование Тогда
		Возврат;
	КонецЕсли;
	
	Параметры.Свойство("Автотестирование", Автотестирование);
	АдресВебКлиента = "https://github.com/lintest/VanessaExt";
	МаскаПоиска = "*.feature";
	ИскомыйТекст = "Браузер";
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ТекстJavaScript = ОбработкаОбъект.ПолучитьМакет("JavaScript").ПолучитьТекст();
	
	AddInURL = Неопределено;
	Если Параметры.Свойство("AddInURL", AddInURL) Тогда
		Файл = Новый Файл(AddInURL);
		Если Файл.Существует() Тогда
			МестоположениеКомпоненты = AddInURL;
		Иначе
			ПолучитьМакетКомпоненты(ОбработкаОбъект)
		КонецЕсли;
	Иначе
		ПолучитьМакетКомпоненты(ОбработкаОбъект)
	КонецЕсли;
	
	Элементы.ДекорацияМышь.Заголовок =
		"Для эмуляции нажатия
		|левой кнопки нажмите F11,
		|правой кнопки мыши F12,
		|двойного щелчка F5";
	
	РазмерПоГоризонтали = 1280;
	РазмерПоВертикали = 960;
	ПортПодключения = 48000;
	ПортБраузера = 9222;
	
	ВизуализацияЦвет = Новый Цвет(200, 50, 50);
	ВизуализацияРадиус = 30;
	ВизуализацияТолщина = 12;
	ВизуализацияДлительность = 12;
	ВизуализацияПрозрачность = 127;
	
	ЦветФигуры = Новый Цвет(200, 50, 50);
	Прозрачность = 127;
	Задержка = 20;
	Таймаут = 3000;
	Толщина = 4;
	
	ФигураX = 200;
	ФигураY = 200;
	ФигураW = 600;
	ФигураH = 300;
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьМакетКомпоненты(ОбработкаОбъект)
	МакетКомпоненты = ОбработкаОбъект.ПолучитьМакет("VanessaExt");
	МестоположениеКомпоненты = ПоместитьВоВременноеХранилище(МакетКомпоненты, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Автотестирование = ПараметрЗапуска = "autotest";

	Если Автотестирование Тогда
		Автотест(Неопределено);
		Отказ = Истина;
	Иначе
		ИдентификаторКомпоненты = "_" + СтрЗаменить(Новый УникальныйИдентификатор, "-", "");
		ВыполнитьПодключениеВнешнейКомпоненты(Истина);
		НайтиБраузер("%ProgramFiles%", Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Автотест(Команда)
	
	Ключи = СтрРазделить(ИмяФормы, ".");
	Ключи[Ключи.Количество() - 1] = "Test";
	ПараметрыФормы = Новый Структура("Автотестирование", Автотестирование);
	ОткрытьФорму(СтрСоединить(Ключи, "."), ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура НайтиБраузер(ПапкаПоиска, ПродолжитьПоиск = Ложь)
	
	СисИнфо = Новый СистемнаяИнформация;
	Если СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86 ИЛИ СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда
		Попытка
			Shell = Новый COMОбъект("WScript.Shell");
			ProgramFiles = Shell.ExpandEnvironmentStrings(ПапкаПоиска);
			ИмяФайла = "\Google\Chrome\Application\chrome.exe";
			Файл = Новый Файл(ProgramFiles + ИмяФайла);
			ДополнительныеПараметры = Новый Структура("ПолноеИмя,ПродолжитьПоиск", Файл.ПолноеИмя, ПродолжитьПоиск);
			ОписаниеОповещения = Новый ОписаниеОповещения("ПроверкаСуществованияФайла", ЭтотОбъект, ДополнительныеПараметры);
			Файл.НачатьПроверкуСуществования(ОписаниеОповещения);
		Исключение
			//Ничего не делаем
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверкаСуществованияФайла(Существует, ДополнительныеПараметры) Экспорт
	
	Если Существует Тогда
		ИнтернетБраузер = ДополнительныеПараметры.ПолноеИмя;
	ИначеЕсли ДополнительныеПараметры.ПродолжитьПоиск Тогда
		НайтиБраузер("%ProgramFiles(x86)%", Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПодключениеВнешнейКомпоненты(ДополнительныеПараметры) Экспорт
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПодключениеВнешнейКомпонентыЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	НачатьПодключениеВнешнейКомпоненты(ОписаниеОповещения, МестоположениеКомпоненты, ИдентификаторКомпоненты, ТипВнешнейКомпоненты.Native);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодключениеВнешнейКомпонентыЗавершение(Подключение, ДополнительныеПараметры) Экспорт
	
	Если Подключение Тогда
		ВнешняяКомпонента = Новый("AddIn." + ИдентификаторКомпоненты + ".WindowsControl");
		БуферОбмена = Новый("AddIn." + ИдентификаторКомпоненты + ".ClipboardControl");
		ОписаниеОповещения = Новый ОписаниеОповещения("ПолученаВерсияКомпоненты", ЭтотОбъект);
		ВнешняяКомпонента.НачатьПолучениеВерсия(ОписаниеОповещения);
	ИначеЕсли ДополнительныеПараметры = Истина Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ВыполнитьПодключениеВнешнейКомпоненты", ЭтотОбъект, Ложь);
		НачатьУстановкуВнешнейКомпоненты(ОписаниеОповещения, МестоположениеКомпоненты);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученаВерсияКомпоненты(Значение, ДополнительныеПараметры) Экспорт
	
	Заголовок = "Управление окнами, версия " + Значение;
	
КонецПроцедуры

&НаКлиенте
Функция ПрочитатьСтрокуJSON(ТекстJSON)
	
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

&НаКлиенте
Функция ЗаписатьСтрокуJSON(Данные)
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Данные);
	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции

&НаКлиенте
Процедура ПолучитьСписокПроцессов(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСписокПроцессов", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСписокПроцессов(ОписаниеОповещения, Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьПроцессы1С(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСписокПроцессов", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСписокПроцессов(ОписаниеОповещения, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученСписокПроцессов(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(РезультатВызова);
	Если ТипЗнч(Данные) = Тип("Массив") Тогда
		СписокПроцессов.Очистить();
		Для каждого Стр из Данные Цикл
			НоваяСтр = СписокПроцессов.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтр, Стр);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьДанныеПроцесса(Команда)
	
	ТекущиеДанные = Элементы.СписокПроцессов.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда Возврат КонецЕсли;
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученыСвойстваОбъекта", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСвойстваПроцесса(ОписаниеОповещения, ТекущиеДанные.ProcessId);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСнимокПроцесса(Команда)
	
	ТекущиеДанные = Элементы.СписокПроцессов.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда Возврат КонецЕсли;
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСнимок", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСнимокПроцесса(ОписаниеОповещения, ТекущиеДанные.ProcessId);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученыСвойстваОбъекта(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(РезультатВызова);
	Если ТипЗнч(Данные) = Тип("Структура") Тогда
		СвойстваОбъекта.Очистить();
		Для каждого КлючЗначение из Данные Цикл
			НоваяСтр = СвойстваОбъекта.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтр, КлючЗначение);
		КонецЦикла;
		Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаСвойстваОбъекта;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСписокОкон(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСписокОкон", ЭтотОбъект);
	ВнешняяКомпонента.НачатьПолучениеСписокОкон(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученСписокОкон(Значение, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(Значение);
	Если ТипЗнч(Данные) = Тип("Массив") Тогда
		СписокОкон.Очистить();
		Для каждого Стр из Данные Цикл
			ЗаполнитьЗначенияСвойств(СписокОкон.Добавить(), Стр);
		КонецЦикла;
		ОписаниеОповещения = Новый ОписаниеОповещения("ПолученоАктивноеОкно", ЭтотОбъект);
		ВнешняяКомпонента.НачатьПолучениеАктивноеОкно(ОписаниеОповещения);
	КонецЕсли;
	
	Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаСписокОкон;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученоАктивноеОкно(Значение, ДополнительныеПараметры) Экспорт
	
	Для каждого Стр из СписокОкон.НайтиСтроки(Новый Структура("window", Значение)) Цикл
		Элементы.СписокОкон.ТекущаяСтрока = Стр.ПолучитьИдентификатор();
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокОконПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.СписокОкон.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		ИдентификаторПроцесса = "";
		ДескрипторОкна = 0;
		ЗаголовокОкна = "";
	Иначе
		ИдентификаторПроцесса = ТекущиеДанные.ProcessId;
		ДескрипторОкна = ТекущиеДанные.window;
		ЗаголовокОкна = ТекущиеДанные.title;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьРазмер(ПозицияПоГоризонтали, ПозицияПоВертикали, РазмерПоГоризонтали, РазмерПоВертикали)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученыСвойстваДисплея", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСвойстваДисплея(ОписаниеОповещения, ДескрипторОкна);
	ВнешняяКомпонента.НачатьВызовУстановитьРазмерОкна(Новый ОписаниеОповещения, ДескрипторОкна, РазмерПоГоризонтали, РазмерПоВертикали);
	ВнешняяКомпонента.НачатьВызовРазрешитьИзменятьРазмер(Новый ОписаниеОповещения, ДескрипторОкна, НЕ ЗапретитьИзменятьРазмер);
	ВнешняяКомпонента.НачатьВызовАктивироватьОкно(Новый ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученыСвойстваДисплея(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(РезультатВызова);
	Если ТипЗнч(Данные) = Тип("Структура") Тогда
		ВнешняяКомпонента.НачатьВызовУстановитьПозициюОкна(
			Новый ОписаниеОповещения, ДескрипторОкна, Данные.Left, Данные.Top
		);
	КонецЕсли;
	
КонецПроцедуры

#Область ТипичныеРазмерыОкон

&НаКлиенте
Процедура ПроизвольныйРазмер(Команда)
	
	УстановитьРазмер(ПозицияПоГоризонтали, ПозицияПоВертикали, РазмерПоГоризонтали, РазмерПоВертикали);
	
КонецПроцедуры

&НаКлиенте
Процедура Размер800х600(Команда)
	УстановитьРазмер(0, 0, 800, 600);
КонецПроцедуры

&НаКлиенте
Процедура Размер960х720(Команда)
	УстановитьРазмер(0, 0, 960, 720);
КонецПроцедуры

&НаКлиенте
Процедура Размер1024х768(Команда)
	УстановитьРазмер(0, 0, 1024, 768);
КонецПроцедуры

&НаКлиенте
Процедура Размер1280х960(Команда)
	УстановитьРазмер(0, 0, 1280, 960);
КонецПроцедуры

&НаКлиенте
Процедура Широкий960х540(Команда)
	УстановитьРазмер(0, 0, 960, 540);
КонецПроцедуры

&НаКлиенте
Процедура Широкий1024х576(Команда)
	УстановитьРазмер(0, 0, 1024, 576);
КонецПроцедуры

&НаКлиенте
Процедура Широкий1280х720(Команда)
	УстановитьРазмер(0, 0, 1280, 720);
КонецПроцедуры

&НаКлиенте
Процедура Широкий1600х900(Команда)
	УстановитьРазмер(0, 0, 1600, 900);
КонецПроцедуры

#КонецОбласти

&НаКлиенте
Процедура СделатьСнимок(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСнимок", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСнимокОкна(ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура СнимокЭкрана(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСнимок", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСнимокЭкрана(ОписаниеОповещения, 0);
	
КонецПроцедуры

&НаКлиенте
Процедура СнимокОкна(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСнимок", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСнимокЭкрана(ОписаниеОповещения, 1);
	
КонецПроцедуры

&НаКлиенте
Процедура СнимокОбластиЭкрана(Команда)

	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСнимок", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСнимокОбласти(ОписаниеОповещения, 
		ПозицияПоГоризонтали, ПозицияПоВертикали, РазмерПоГоризонтали, РазмерПоВертикали);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученСнимок(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	ДанныеКартинки = ПоместитьВоВременноеХранилище(РезультатВызова, УникальныйИдентификатор);
	Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаКартинка;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьЗаголовокОкна(Команда)
	
	НовыйЗаголовок = Строка(Новый УникальныйИдентификатор);
	ВнешняяКомпонента.НачатьВызовУстановитьЗаголовок(Новый ОписаниеОповещения, ДескрипторОкна, НовыйЗаголовок);
	
КонецПроцедуры

&НаКлиенте
Процедура Активировать(Команда)
	
	ВнешняяКомпонента.НачатьВызовАктивироватьОкно(Новый ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура Распахнуть(Команда)
	
	ВнешняяКомпонента.НачатьВызовРаспахнутьОкно(Новый ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура Свернуть(Команда)
	
	ВнешняяКомпонента.НачатьВызовСвернутьОкно(Новый ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура Развернуть(Команда)
	
	ВнешняяКомпонента.НачатьВызовРазвернутьОкно(Новый ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура НайтиКлиентТестирования(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученКлиентТестирования", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовНайтиКлиентТестирования(ОписаниеОповещения, ПортПодключения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученКлиентТестирования(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	ДескрипторОкна = 0;
	СвойстваОбъекта.Очистить();
	Данные = ПрочитатьСтрокуJSON(РезультатВызова);
	Если ТипЗнч(Данные) = Тип("Структура") Тогда
		Данные.Свойство("ProcessId", ИдентификаторПроцесса);
		Данные.Свойство("Window", ДескрипторОкна);
		Данные.Свойство("Title", ЗаголовокОкна);
		Для каждого КлючЗначение из Данные Цикл
			НоваяСтр = СвойстваОбъекта.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтр, КлючЗначение);
		КонецЦикла;
		Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаСвойстваОбъекта;
	Иначе
		ИдентификаторПроцесса = Неопределено;
		ДескрипторОкна = Неопределено;
		ЗаголовокОкна = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСвойстваОкна(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученыСвойстваОбъекта", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСвойстваОкна(ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьРазмерОкна(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученыСвойстваОбъекта", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьРазмерОкна(ОписаниеОповещения, ДескрипторОкна);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьОкнаПроцесса(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСписокОконПроцесса", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьСписокОкон(ОписаниеОповещения, ИдентификаторПроцесса);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученСписокОконПроцесса(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(РезультатВызова);
	Если ТипЗнч(Данные) = Тип("Массив") Тогда
		СписокОкон.Очистить();
		Для каждого Стр из Данные Цикл
			ЗаполнитьЗначенияСвойств(СписокОкон.Добавить(), Стр);
		КонецЦикла;
	КонецЕсли;
	
	Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаСписокОкон;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСписокДисплеев(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСписокДисплеев", ЭтотОбъект);
	ВнешняяКомпонента.НачатьПолучениеСписокДисплеев(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученСписокДисплеев(Значение, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(Значение);
	Если ТипЗнч(Данные) = Тип("Массив") Тогда
		СписокДисплеев.Очистить();
		Для каждого Стр из Данные Цикл
			НоваяСтр = СписокДисплеев.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтр, Стр);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСвойстваЭкрана(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученыСвойстваЭкрана", ЭтотОбъект);
	ВнешняяКомпонента.НачатьПолучениеСвойстваЭкрана(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученыСвойстваЭкрана(Значение, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(Значение);
	Если ТипЗнч(Данные) = Тип("Структура") Тогда
		СвойстваОбъекта.Очистить();
		Для каждого КлючЗначение из Данные Цикл
			Если ТипЗнч(КлючЗначение.Значение) = Тип("Структура") Тогда
				Для каждого КЗ из КлючЗначение.Значение Цикл
					НоваяСтр = СвойстваОбъекта.Добавить();
					НоваяСтр.Ключ = КлючЗначение.Ключ + "." + КЗ.Ключ;
					НоваяСтр.Значение = КЗ.Значение;
				КонецЦикла;
			Иначе
				ЗаполнитьЗначенияСвойств(СвойстваОбъекта.Добавить(), КлючЗначение);
			КонецЕсли;
		КонецЦикла;
		Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаСвойстваОбъекта;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьТекстИзБуфера(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученТекстБуфераОбмена", ЭтотОбъект);
	ВнешняяКомпонента.НачатьПолучениеТекстБуфераОбмена(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура КопироватьТекстВБуфер(Команда)
	
	ВнешняяКомпонента.НачатьУстановкуТекстБуфераОбмена( , ТекстБуфераОбмена);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученТекстБуфераОбмена(Значение, ДополнительныеПараметры) Экспорт
	
	ТекстБуфераОбмена = Значение;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьКартинкуИзБуфера(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученаКартинкаБуфераОбмена", ЭтотОбъект);
	ВнешняяКомпонента.НачатьПолучениеКартинкаБуфераОбмена(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученаКартинкаБуфераОбмена(Значение, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(Значение) = Тип("ДвоичныеДанные") Тогда
		ДанныеКартинки = ПоместитьВоВременноеХранилище(Значение, УникальныйИдентификатор);
		Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаКартинка;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьЛоготип1С(УникальныйИдентификатор)
	
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
	ДвоичныеДанные = Картинка.ПолучитьДвоичныеДанные(Ложь, Соответствие);
	Возврат ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
	
КонецФункции

&НаКлиенте
Процедура КопироватьКартинкуВБуфер(Команда)
	
	АдресХранилища = ПолучитьЛоготип1С(УникальныйИдентификатор);
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресХранилища);
	ВнешняяКомпонента.НачатьУстановкуКартинкаБуфераОбмена( , ДвоичныеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ФорматБуфераОбмена(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученТекстБуфераОбмена", ЭтотОбъект);
	ВнешняяКомпонента.НачатьПолучениеФорматБуфераОбмена(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьБуферОбмена(Команда)
	
	ВнешняяКомпонента.НачатьВызовОчиститьБуферОбмена(Новый ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТекст(Команда)
	
	ТекстБуфераОбмена = Формат(ТекущаяДата(), "ДЛФ=DDT");
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьТекст(Команда)
	
	ТекстБуфераОбмена = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура КопироватьСнимокВБуферОбмена(Команда)
	
	Если ПустаяСтрока(ДанныеКартинки) Тогда Возврат КонецЕсли;
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(ДанныеКартинки);
	ВнешняяКомпонента.НачатьУстановкуКартинкаБуфераОбмена( , ДвоичныеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ПаузаSleep(Команда)
	
	ТекДата = ТекущаяДата();
	ТекстБуфераОбмена = Формат(ТекДата, "ДЛФ=DDT");
	ОписаниеОповещения = Новый ОписаниеОповещения("ВызовПауза", ЭтотОбъект, ТекДата);
	ВнешняяКомпонента.НачатьВызовПауза(ОписаниеОповещения, 1000);
	
КонецПроцедуры

&НаКлиенте
Процедура ВызовПауза(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	ТекстБуфераОбмена = Формат(ДополнительныеПараметры, "ДЛФ=DDT") + Символы.ПС + Формат(ТекущаяДата(), "ДЛФ=DDT");
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьПозициюКурсора(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученаПозицияКурсора", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПолучитьПозициюКурсора(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученаПозицияКурсора(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	Данные = ПрочитатьСтрокуJSON(РезультатВызова);
	Если ТипЗнч(Данные) = Тип("Структура") Тогда
		ПозицияКурсораX = Данные.X;
		ПозицияКурсораY = Данные.Y;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПозициюКурсора(Команда)
	
	ВнешняяКомпонента.НачатьВызовУстановитьПозициюКурсора(Новый ОписаниеОповещения, ПозицияКурсораX, ПозицияКурсораY);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьБраузер(Команда)
	
	СтрокаКоманды = """" + ИнтернетБраузер + """ about:blank --remote-debugging-port=" + Формат(ПортБраузера, "ЧГ=");
	НачатьЗапускПриложения(Новый ОписаниеОповещения, СтрокаКоманды);
	
КонецПроцедуры

&НаКлиенте
Процедура ИнтернетБраузерНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВыбранФайлБраузера", ЭтотОбъект);
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла = Истина;
	ДиалогВыбораФайла.МножественныйВыбор = Ложь;
	ДиалогВыбораФайла.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбранФайлБраузера(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(ВыбранныеФайлы) = Тип("Массив") Тогда
		Для каждого ЭлементМассива из ВыбранныеФайлы Цикл
			ИнтернетБраузер = ЭлементМассива;
			Прервать;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗаголовокКоманды(ИмяКоманды)
	
	Возврат Команды.Найти(ИмяКоманды).Заголовок;
	
КонецФункции

&НаКлиенте
Процедура ОшибкаБраузера(Команда)
	
	ИнформационныйТекст =
		"Перед вызовом команды «" + ЗаголовокКоманды(Команда.Имя) + "»
		|закройте все открытые окна Google Chrome
		|и запустите снова кнопкой «Запустить браузер».";
	ПоказатьПредупреждение( , ИнформационныйТекст, 10);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьURL(Команда)
	
	HTTPЗапрос = Новый HTTPЗапрос("/json/new?" + АдресВебКлиента);
	HTTPСоединение = Новый HTTPСоединение("localhost", 9222, , , , 10);
	Попытка
		HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос);
	Исключение
		ОшибкаБраузера(Команда);
		Возврат;
	КонецПопытки;
	ТекстJSON = HTTPОтвет.ПолучитьТелоКакСтроку();
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(ТекстJSON);
	ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
	АдресВебСокет = ДанныеJSON.webSocketDebuggerUrl;
	
	ОписаниеОповещения = Новый ОписаниеОповещения;
	ВнешняяКомпонента.НачатьВызовОткрытьВебСокет(ОписаниеОповещения, АдресВебСокет);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьJavaSctipt(Команда)
	
	ПараметрыМетода = Новый Структура("expression", ТекстJavaScript);
	ДанныеJSON = Новый Структура("id,method,params", 1, "Runtime.evaluate", ПараметрыМетода);
	ЗаписьJSON = новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ДанныеJSON);
	КомандаJSON = ЗаписьJSON.Закрыть();
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВызовJavaSctipt", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовПослатьВебСокет(ОписаниеОповещения, КомандаJSON);
	
КонецПроцедуры

&НаКлиенте
Процедура ВызовJavaSctipt(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	РезультатJSON = РезультатВызова;
	
КонецПроцедуры

&НаКлиенте
Процедура СнимокЭкранаБраузера(Команда)
	
	ПараметрыМетода = Новый Структура("format,quality,fromSurface", "png", 85, Ложь);
	ДанныеJSON = Новый Структура("id,method,params", 1, "Page.captureScreenshot", ПараметрыМетода);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ДанныеJSON);
	КомандаJSON = ЗаписьJSON.Закрыть();
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСнимокБраузера", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовВебСокет(ОписаниеОповещения, АдресВебСокет, КомандаJSON);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученСнимокБраузера(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(РезультатВызова);
	ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
	Если ДанныеJSON.Свойство("result") Тогда
		ДвоичныеДанные = Base64Значение(ДанныеJSON.result.data);
		ДанныеКартинки = ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
		Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.СтраницаКартинка;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВызватьМетодDevTools(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВызовJavaSctipt", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовВебСокет(ОписаниеОповещения, АдресВебСокет, КомандаJSON);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭмуляцияВвода(Команда)
	
	Текст = Формат(ТекущаяДата(), "ДЛФ=DDT");
	Если Не ПустаяСтрока(ТекстБуфераОбмена) Тогда
		Текст = Символы.ПС + Текст;
	КонецЕсли;
	ТекущийЭлемент = Элементы.ТекстБуфераОбмена;
	ВнешняяКомпонента.НачатьВызовЭмуляцияВводаТекста(Новый ОписаниеОповещения, Текст, 0);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭмуляцияКлавиши(СочетаниеКлавиш)
	
	Перем Клавиша, Флаги;
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку();
	ЗаписатьXML(ЗаписьXML, СочетаниеКлавиш);
	ТекстXML = ЗаписьXML.Закрыть();
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(ТекстXML);
	ПостроительDOM = Новый ПостроительDOM;
	ДокументDOM = ПостроительDOM.Прочитать(ЧтениеXML);
	КорневойУзел = ДокументDOM.ПервыйДочерний;
	Для каждого ДочернийУзел из КорневойУзел.ДочерниеУзлы Цикл
		Если ДочернийУзел.ИмяУзла = "vKey" Тогда
			Клавиша = Число(ДочернийУзел.ТекстовоеСодержимое);
		ИначеЕсли ДочернийУзел.ИмяУзла = "flags" Тогда
			Флаги = Число(ДочернийУзел.ТекстовоеСодержимое);
		КонецЕсли;
	КонецЦикла;
	ВнешняяКомпонента.НачатьВызовЭмуляцияНажатияКлавиши(Новый ОписаниеОповещения, Клавиша, Флаги);
	
КонецПроцедуры

&НаКлиенте
Процедура НажатиеКлавишиCtrlF2(Команда)
	
	ЭмуляцияКлавиши(Новый СочетаниеКлавиш(Клавиша.F2, Ложь, Истина, Ложь));
	
КонецПроцедуры

&НаКлиенте
Процедура НажатиеКлавишиWinE(Команда)
	
	Массив = Новый Массив;
	Массив.Добавить(91); // VK_LWIN = 0x5B = 91
	Массив.Добавить(КодСимвола("E"));
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Массив);
	ТекстJSON = ЗаписьJSON.Закрыть();
	
	ВнешняяКомпонента.НачатьВызовЭмуляцияНажатияКлавиши(Новый ОписаниеОповещения, ТекстJSON);
	
КонецПроцедуры

&НаКлиенте
Процедура НажатиеКлавишиNumLock(Команда)
	
	ТекстJSON = "[144]"; // VK_NUMLOCK = 0x90 = 144
	ВнешняяКомпонента.НачатьВызовЭмуляцияНажатияКлавиши(Новый ОписаниеОповещения, ТекстJSON);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭмуляцияДвиженияМыши(Команда)
	
	ВнешняяКомпонента.НачатьВызовЭмуляцияДвиженияМыши(Новый ОписаниеОповещения, ПозицияКурсораX, ПозицияКурсораY, 1000, 3);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭмуляцияНажатияМыши(Команда)
	
	ВнешняяКомпонента.НачатьВызовЭмуляцияНажатияМыши(Новый ОписаниеОповещения, 0);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭмуляцияПравойКнопкиМыши(Команда)
	
	ВнешняяКомпонента.НачатьВызовЭмуляцияНажатияМыши(Новый ОписаниеОповещения, 1);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭмуляцияДвойногоНажатия(Команда)
	
	ВнешняяКомпонента.НачатьВызовЭмуляцияДвойногоНажатия(Новый ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПроцессовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ПолучитьДанныеПроцесса(Неопределено);
	
КонецПроцедуры

&НаСервере
Процедура ВызовКонтекстаСервераНаСервере()
	ТекстБуфераОбмена = Формат(ТекущаяУниверсальнаяДата(), "ДЛФ=DDT");
КонецПроцедуры

&НаКлиенте
Процедура ВызовКонтекстаСервера(Команда)
	ВызовКонтекстаСервераНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура НайтиФайлыКомпонентой(Команда)
	
	СписокФайлов.Очистить();
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученРезультатПоиска", ЭтотОбъект);
	ВнешняяКомпонента.НачатьВызовНайтиФайлы(ОписаниеОповещения, Директория, МаскаПоиска, ИскомыйТекст, ИгнорироватьРегистр);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученРезультатПоиска(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	СписокФайлов.Очистить();
	Данные = ПрочитатьСтрокуJSON(РезультатВызова);
	Если ТипЗнч(Данные) = Тип("Массив") Тогда
		Для каждого Стр Из Данные Цикл
			НоваяСтр = СписокФайлов.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтр, Стр);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция АбсолютыйЦветСервер(ИсходныйЦвет)
	ТабДок = Новый ТабличныйДокумент;
	ТабДок.Область("R1C1").ЦветФона = ИсходныйЦвет;
	ВременныйФайл = ПолучитьИмяВременногоФайла("mxl");
	ТабДок.Записать(ВременныйФайл, ТипФайлаТабличногоДокумента.MXL7);
	ТабДок.Прочитать(ВременныйФайл);
	УдалитьФайлы(ВременныйФайл);
	Возврат ТабДок.Область("R1C1").ЦветФона;
КонецФункции

&НаКлиенте
Функция ЦветКакЧисло(Знач Цвет)
	
	Если Цвет.Красный < 0 ИЛИ Цвет.Зеленый < 0 ИЛИ Цвет.Синий < 0 Тогда
		Цвет = АбсолютыйЦветСервер(Цвет);
	КонецЕсли;
	Возврат Цвет.Красный + Цвет.Зеленый * 256 + Цвет.Синий * 256 * 256;
	
КонецФункции

&НаКлиенте
Процедура ВизуализацияНажатияПоказать(Команда)
	
	ВнешняяКомпонента.НачатьВызовПоказатьНажатиеМыши(
		Новый ОписаниеОповещения,
		ЦветКакЧисло(ВизуализацияЦвет),
		ВизуализацияРадиус,
		ВизуализацияТолщина,
		ВизуализацияДлительность,
		ВизуализацияПрозрачность
	);
	
КонецПроцедуры

&НаКлиенте
Процедура ВизуализацияНажатияВключить(Команда)
	
	ВнешняяКомпонента.НачатьВызовВизуализацияНажатияМыши(
		Новый ОписаниеОповещения,
		ЦветКакЧисло(ВизуализацияЦвет),
		ВизуализацияРадиус,
		ВизуализацияТолщина,
		ВизуализацияДлительность,
		ВизуализацияПрозрачность
	);
	
КонецПроцедуры

&НаКлиенте
Процедура ВизуализацияНажатияПрекратить(Команда)
	
	ВнешняяКомпонента.НачатьВызовПрекратитьВизуализациюНажатияМыши(Новый ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОшибкаКонвертации(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения;
	ВнешняяКомпонента.НачатьВызовНайтиКлиентТестирования(ОписаниеОповещения, "текст");
	ВнешняяКомпонента.НачатьВызовЭмуляцияВводаТекста(ОписаниеОповещения, "текст", Неопределено);
	ВнешняяКомпонента.НачатьВызовЭмуляцияВводаТекста(ОписаниеОповещения, 10);
	ВнешняяКомпонента.НачатьУстановкуТекстБуфераОбмена(ОписаниеОповещения, 0);
	
КонецПроцедуры

&НаКлиенте
Процедура ВоспроизвестиЗвукСинхронно(Команда)
	
	ВнешняяКомпонента.НачатьВызовВоспроизвестиЗвук(Новый ОписаниеОповещения, ЗвуковойФайл, Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ВоспроизвестиЗвукАсинхронно(Команда)
	
	ВнешняяКомпонента.НачатьВызовВоспроизвестиЗвук(Новый ОписаниеОповещения, ЗвуковойФайл, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ВоспроизвестиЗвукПрекратить(Команда)
	
	ВнешняяКомпонента.НачатьВызовВоспроизвестиЗвук(Новый ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗвуковойФайлНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаВыбораЗвуковогоФайла", ЭтаФорма);
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = "Звуковой файл (*.wav)|*.wav";
	ДиалогВыбораФайла.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбораЗвуковогоФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		ЗвуковойФайл = ВыбранныеФайлы[0];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаФайлНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаВыбораМультимедиаФайла", ЭтаФорма);
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = "Мультимедиа файл (*.mp3)|*.mp3";
	ДиалогВыбораФайла.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбораМультимедиаФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		МультимедиаФайл = ВыбранныеФайлы[0];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаКоманда(МедиаКоманда)
	
	ВнешняяКомпонента.НачатьВызовМедиаКоманда(Новый ОписаниеОповещения, МедиаКоманда);
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаOpen(Команда)
	
	МультимедиаКоманда("OPEN """ + МультимедиаФайл + """ TYPE MpegVideo ALIAS MP3");
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаPlay(Команда)
	
	МультимедиаКоманда("PLAY MP3 from 0");
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаPause(Команда)
	
	МультимедиаКоманда("PAUSE MP3");
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаStop(Команда)
	
	МультимедиаКоманда("STOP MP3");
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаResume(Команда)
	
	МультимедиаКоманда("RESUME MP3");
	
КонецПроцедуры

&НаКлиенте
Процедура МультимедиаSize(Команда)
	
	МедиаКоманда = "status MP3 length";
	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученаДлинаМультимедиа", ЭтаФорма);
	ВнешняяКомпонента.НачатьВызовМедиаКоманда(ОписаниеОповещения, МедиаКоманда);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученаДлинаМультимедиа(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	Сообщить("Длина мультимедиа файла: " + РезультатВызова);
	
КонецПроцедуры

&НаКлиенте
Процедура МедиаВоспроизвести(Команда)
	
	ИдентификаторМедиа = Строка(Новый УникальныйИдентификатор);
	ВнешняяКомпонента.НачатьВызовВоспроизвестиМедиа(Новый ОписаниеОповещения, ИдентификаторМедиа, МультимедиаФайл);
	
КонецПроцедуры

&НаКлиенте
Процедура МедиаПрервать(Команда)

	ВнешняяКомпонента.НачатьВызовВоспроизвестиМедиа(Новый ОписаниеОповещения, ИдентификаторМедиа);
	
КонецПроцедуры

&НаКлиенте
Процедура МедиаСтатус(Команда)

	ОписаниеОповещения = Новый ОписаниеОповещения("ПолученСтатусМедиа", ЭтаФорма);
	ВнешняяКомпонента.НачатьВызовВоспроизводитсяМедиа(ОписаниеОповещения, ИдентификаторМедиа);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолученСтатусМедиа(РезультатВызова, ПараметрыВызова, ДополнительныеПараметры) Экспорт
	
	Сообщить("Статус медиа: " + ?(РезультатВызова, "Воспроизводится", "Остановлен"));
	
КонецПроцедуры

&НаКлиенте
Процедура ПапкаКартинокНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	ОписаниеОповещения = Новый ОписаниеОповещения("ВыборПапкиКартинок", ЭтаФорма);
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ДиалогВыбораФайла.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборПапкиКартинок(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено Тогда
		ПапкаКартинок = ВыбранныеФайлы[0];
		ОписаниеОповещения = Новый ОписаниеОповещения("НайденыФайлыКартинок", ЭтаФорма);
		НачатьПоискФайлов(ОписаниеОповещения, ПапкаКартинок, "*.png", Ложь)
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НайденыФайлыКартинок(НайденныеФайлы, ДополнительныеПараметры) Экспорт
	
	ТаблицаКартинок.Очистить();
	Для каждого ФайлКартинки из НайденныеФайлы Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаКартинок.Добавить(), ФайлКартинки);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаКартинокПриАктивизацииСтроки(Элемент)
	
	Если Не ПустаяСтрока(АдресФрагментаКартинки) Тогда
		УдалитьИзВременногоХранилища(АдресФрагментаКартинки);
		АдресФрагментаКартинки = Неопределено;
	КонецЕсли;
	
	ТекущиеДанные = Элементы.ТаблицаКартинок.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ФрагментКартинки = Новый ДвоичныеДанные(ТекущиеДанные.ПолноеИмя);
	АдресФрагментаКартинки = ПоместитьВоВременноеХранилище(ФрагментКартинки, УникальныйИдентификатор);
	
	ПодключитьОбработчикОжидания("НайтиФрагментКартинки", 1, Истина);
	
КонецПроцедуры	

&НаКлиенте
Процедура НайтиФрагментКартинки() Экспорт
	
	Если Не ПустаяСтрока(АдресФрагментаКартинки) Тогда
		УдалитьИзВременногоХранилища(АдресФрагментаКартинки);
		АдресФрагментаКартинки = Неопределено;
	КонецЕсли;
	
	ТекущиеДанные = Элементы.ТаблицаКартинок.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ФрагментКартинки = Новый ДвоичныеДанные(ТекущиеДанные.ПолноеИмя);
	АдресФрагментаКартинки = ПоместитьВоВременноеХранилище(ФрагментКартинки, УникальныйИдентификатор);
	ТекстJSON = ВнешняяКомпонента.НайтиНаЭкране(ФрагментКартинки);
	Координаты = ПрочитатьСтрокуJSON(ТекстJSON);
	Если Координаты = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВремСтруктура = Новый Структура;
	ВремСтруктура.Вставить("color", 255);
	ВремСтруктура.Вставить("transparency", 255);
	ВремСтруктура.Вставить("duration", 3000);
	ВремСтруктура.Вставить("thickness", 2);
	НастройкиРисования = ЗаписатьСтрокуJSON(ВремСтруктура);
	
	ВнешняяКомпонента.НачатьВызовНарисоватьПрямоугольник(Новый ОписаниеОповещения, 
		НастройкиРисования, Координаты.Left, Координаты.Top, Координаты.Width, Координаты.Height);

КонецПроцедуры

&НаКлиенте
Функция ПолучитьНастройкиРисования()
	
	ТекстПодсказки = 
	"Пример длинного текста подсказки для
	|эффекта затенения области экрана";
	
	ВремСтруктура = Новый Структура;
	ВремСтруктура.Вставить("color", ЦветКакЧисло(ЦветФигуры));
	ВремСтруктура.Вставить("transparency", Прозрачность);
	ВремСтруктура.Вставить("duration", Таймаут);
	ВремСтруктура.Вставить("thickness", Толщина);
	ВремСтруктура.Вставить("frameDelay", Задержка);
	ВремСтруктура.Вставить("text", ТекстПодсказки);
	Возврат ЗаписатьСтрокуJSON(ВремСтруктура);
	
КонецФункции

&НаКлиенте
Процедура ФигураПрямоугольник(Команда)

	НастройкиРисования = ПолучитьНастройкиРисования();
	ВнешняяКомпонента.НачатьВызовНарисоватьПрямоугольник(
		Новый ОписаниеОповещения, НастройкиРисования, 
		ФигураX, ФигураY, ФигураW, ФигураH);
	
КонецПроцедуры

&НаКлиенте
Процедура ФигураЭллипс(Команда)

	НастройкиРисования = ПолучитьНастройкиРисования();
	ВнешняяКомпонента.НачатьВызовНарисоватьЭллипс(
		Новый ОписаниеОповещения, НастройкиРисования, 
		ФигураX, ФигураY, ФигураW, ФигураH);
	
КонецПроцедуры

&НаКлиенте
Процедура ФигураЗатенение(Команда)

	НастройкиРисования = ПолучитьНастройкиРисования();
	ВнешняяКомпонента.НачатьВызовНарисоватьТень(
		Новый ОписаниеОповещения, НастройкиРисования, 
		ФигураX, ФигураY, ФигураW, ФигураH);
	
КонецПроцедуры

&НаКлиенте
Процедура ФигураПрямаяСтрелка(Команда)

	НастройкиРисования = ПолучитьНастройкиРисования();
	ВнешняяКомпонента.НачатьВызовНарисоватьСтрелку(
		Новый ОписаниеОповещения, НастройкиРисования, 
		ФигураX, ФигураY + ФигураH, ФигураX + ФигураW, ФигураY);
	
КонецПроцедуры

&НаКлиенте
Процедура ФигураКриваяСтрелка(Команда)

	Массив = Новый Массив;
	Массив.Добавить(Новый Структура("x,y", 100, 500));
	Массив.Добавить(Новый Структура("x,y", 300, 500));
	Массив.Добавить(Новый Структура("x,y", 300, 700));
	Массив.Добавить(Новый Структура("x,y", 500, 700));
	ТекстJSON = ЗаписатьСтрокуJSON(Массив);
	
	НастройкиРисования = ПолучитьНастройкиРисования();
	ВнешняяКомпонента.НачатьВызовНарисоватьКривую(
		Новый ОписаниеОповещения, НастройкиРисования, ТекстJSON);
	
КонецПроцедуры

&НаКлиенте
Процедура АктивироватьПроцесс(Команда)

	ТекущиеДанные = Элементы.СписокПроцессов.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда Возврат КонецЕсли;
	ВнешняяКомпонента.НачатьВызовАктивироватьПроцесс(Новый ОписаниеОповещения, ТекущиеДанные.ProcessId);
	
КонецПроцедуры

&НаКлиенте
Процедура ВывестиВКонсоль(Команда)
	
	ВнешняяКомпонента.НачатьВызовВывестиВКонсоль(Новый ОписаниеОповещения, ТекстКонсоли);
	
КонецПроцедуры

&НаКлиенте
Процедура МониторингБуфераОбменаПриИзменении(Элемент)
	
	БуферОбмена.НачатьУстановкуМониторинг(Новый ОписаниеОповещения, МониторингБуфераОбмена);
	
КонецПроцедуры

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	
	Сообщить("Внешнее событие: " + Источник 
		+ Символы.ПС + "  " + Событие
		+ Символы.ПС + "  " + Данные
	);
	
КонецПроцедуры
