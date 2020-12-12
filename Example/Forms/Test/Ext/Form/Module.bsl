﻿&НаСервере
Перем Соединение, МодульСервера, КоличествоТестов, КоличествоОшибок, КоличествоПроблем, ИмяФайлаОбработки, ВремяСтарта;

&НаСервере
Перем ИдКомпоненты, АдресКомпоненты, PID, hWnd;

&НаСервере
Перем Значение, ВК, ПК, Буф, git;

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

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("Автотестирование", Автотестирование);
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ФайлОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	ИмяФайлаОбработки = ФайлОбработки.Имя;
	ТекущийКаталог = ФайлОбработки.Путь;
	
	ИдКомпоненты = "_" + StrReplace(New UUID, "-", "");
	МакетКомпоненты = ОбработкаОбъект.ПолучитьМакет("VanessaExt");
	АдресКомпоненты = ПоместитьВоВременноеХранилище(МакетКомпоненты, УникальныйИдентификатор);
	
	КоличествоТестов = 0;
	КоличествоОшибок = 0;
	КоличествоПроблем = 0;
	
	Если Автотестирование Тогда
		Попытка
			МодульСервера = Вычислить("AppServer");
			Соединение = МодульСервера.СоздатьСоединение();
			ВыполнитьТесты();
			Если КоличествоОшибок = 0 И КоличествоПроблем = 0 Тогда
				ЗаписьТекста = Новый ЗаписьТекста(ТекущийКаталог + "success.txt");
				ЗаписьТекста.ЗаписатьСтроку(ТекущаяУниверсальнаяДата());
				ЗаписьТекста.Закрыть();
			КонецЕсли;
		Исключение
			Лог = Новый ЗаписьТекста(ТекущийКаталог + "autotest.log");
			Лог.ЗаписатьСтроку(ИнформацияОбОшибке().Описание);
			Лог.Закрыть();
		КонецПопытки;
	Иначе
		ВыполнитьТесты();
	КонецЕсли;
	
КонецПроцедуры

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
	
	ВремяСтарта = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Стр = Родитель.ПолучитьЭлементы().Добавить();
	СписокУзлов.Добавить(Стр.ПолучитьИдентификатор());
	Стр.Наименование = Наименование;
	Возврат Стр;
	
КонецФункции

&НаСервере
Процедура УстановитьФлагОшибки(ТекСтр)
	
	Если Автотестирование Тогда
		МодульСервера.ОтправитьСообщение(Соединение, ТекСтр.Наименование, "Error", ТекСтр.Результат);
	КонецЕсли;
	
	Стр = ТекСтр;
	Пока Стр <> Неопределено Цикл
		Стр.Ошибка = Истина;
		Стр = Стр.ПолучитьРодителя();
	КонецЦикла;
	
	КоличествоОшибок = КоличествоОшибок + 1;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФлагПроблемы(ТекСтр)
	
	Если Автотестирование Тогда
		МодульСервера.ОтправитьСообщение(Соединение, ТекСтр.Наименование, "Warning", ТекСтр.Результат);
	КонецЕсли;
	
	Стр = ТекСтр;
	Пока Стр <> Неопределено Цикл
		Стр.Проблема = Истина;
		Стр = Стр.ПолучитьРодителя();
	КонецЦикла;
	
	КоличествоПроблем = КоличествоПроблем + 1;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьГруппуТестов(ТекСтр)
	
	Если Автотестирование Тогда
		Статус = ?(ТекСтр.Ошибка, "Failed", ?(ТекСтр.Проблема, "Inconclusive", "Passed"));
		Длительность = ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяСтарта;
		МодульСервера.ОтправитьТест(Соединение, ТекСтр.Наименование, ИмяФайлаОбработки, Длительность, Статус);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ТестВычислить(Группа, ИмяТеста, Выражение, Эталон = "")
	
	КоличествоТестов = КоличествоТестов + 1;
	Стр = Группа.ПолучитьЭлементы().Добавить();
	Стр.Наименование = ИмяТеста;
	Стр.Выражение = Выражение;
	Попытка
		Значение = Вычислить(Выражение);
		Стр.Результат = Значение;
		Стр.Подробности = Значение;
		Если Не ПустаяСтрока(Эталон) Тогда
			Стр.Эталон = Эталон;
			Попытка
				РезультатПроверки = Вычислить(Эталон) = Истина;
			Исключение
				РезультатПроверки = Ложь;
				Информация = ИнформацияОбОшибке();
				Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
			КонецПопытки;
			Если Не РезультатПроверки Тогда
				УстановитьФлагПроблемы(Стр);
			КонецЕсли;
		КонецЕсли;
	Исключение
		Значение = Неопределено;
		Информация = ИнформацияОбОшибке();
		Стр.Результат = КраткоеПредставлениеОшибки(Информация);
		Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
		УстановитьФлагОшибки(Стр);
	КонецПопытки;
	
	Возврат Значение;
	
КонецФункции

&НаСервере
Процедура ТестВыполнить(Группа, ИмяТеста, Выражение, Эталон = "")
	
	КоличествоТестов = КоличествоТестов + 1;
	Стр = Группа.ПолучитьЭлементы().Добавить();
	Стр.Наименование = ИмяТеста;
	Стр.Выражение = Выражение;
	Попытка
		Выполнить(Выражение);
		Если Не ПустаяСтрока(Эталон) Тогда
			Стр.Эталон = Эталон;
			Попытка
				РезультатПроверки = Вычислить(Эталон) = Истина;
			Исключение
				РезультатПроверки = Ложь;
				Информация = ИнформацияОбОшибке();
				Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
			КонецПопытки;
			Если Не РезультатПроверки Тогда
				УстановитьФлагПроблемы(Стр);
			КонецЕсли;
		КонецЕсли;
	Исключение
		Значение = Неопределено;
		Информация = ИнформацияОбОшибке();
		Стр.Результат = КраткоеПредставлениеОшибки(Информация);
		Стр.Подробности = ПодробноеПредставлениеОшибки(Информация);
		УстановитьФлагОшибки(Стр);
	КонецПопытки;
	
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
Процедура ВыполнитьТесты()
	
	Группа = ДобавитьГруппуТестов(Результаты, "Инициализация библиотеки");
	ТестВычислить(Группа, "ПодключениеБиблиотеки", "ПодключитьВнешнююКомпоненту(АдресКомпоненты, ИдКомпоненты, ТипВнешнейКомпоненты.Native)");
	ВК = ТестВычислить(Группа, "Новый:WindowsControl", "Новый(""AddIn." + ИдКомпоненты + ".WindowsControl"")");
	ПК = ТестВычислить(Группа, "Новый:ProcessControl", "Новый(""AddIn." + ИдКомпоненты + ".ProcessControl"")");
	Буф = ТестВычислить(Группа, "Новый:ClipboardControl", "Новый(""AddIn." + ИдКомпоненты + ".ClipboardControl"")");
	git = ТестВычислить(Группа, "Новый:GitFor1C", "Новый(""AddIn." + ИдКомпоненты + ".GitFor1C"")");
	ЗаписатьГруппуТестов(Группа);
	
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
	Размеры = JSON(Значение);
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