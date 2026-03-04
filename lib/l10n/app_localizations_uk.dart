// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get author => 'Автор';

  @override
  String get title => 'Назва';

  @override
  String get link => 'Лінк';

  @override
  String get notes => 'Нотатки';

  @override
  String get how_do_you_like_the_book => 'Сподобалась книга?';

  @override
  String get please_wait_momemt => 'Зачекай хвилинку';

  @override
  String get books => 'Книги';

  @override
  String get wait_while_log_you_in => 'Please wait while I log you in';

  @override
  String get logout_button => 'Вийти';

  @override
  String get note => 'Книга';

  @override
  String get cancel => 'Скасувати';

  @override
  String get yes => 'Так';

  @override
  String get delete => 'Видалити';

  @override
  String get sharing => 'Поділитися';

  @override
  String get ok => 'Ок';

  @override
  String get login => 'Увійти';

  @override
  String get verify_email => 'Підтвердити пошту';

  @override
  String get register => 'Зареєструватися';

  @override
  String get restart => 'Перезапустити';

  @override
  String get start_typing_your_note => 'Почни писати книгу';

  @override
  String get delete_note_prompt => 'Точно хочеш видалити цю книгу?';

  @override
  String get cannot_share_empty_note_prompt =>
      'Не можна поділитися порожньою книгою!';

  @override
  String get generic_error_prompt => 'Сталася помилка';

  @override
  String get logout_dialog_prompt => 'Ти впевнений, що хочеш вийти?';

  @override
  String get password_reset => 'Скидання пароля';

  @override
  String get password_reset_dialog_prompt =>
      'Ми надіслали тобі лист для скидання пароля. Перевір пошту для деталей.';

  @override
  String get login_error_cannot_find_user =>
      'Не можемо знайти користувача з такими даними!';

  @override
  String get login_error_wrong_credentials => 'Неправильні дані для входу';

  @override
  String get login_error_auth_error => 'Помилка авторизації';

  @override
  String get login_view_prompt =>
      'Увійди в свій акаунт, щоб створювати та редагувати книги!';

  @override
  String get login_view_email_and_password_cannot_be_empty =>
      'Перевір пошту та пароль';

  @override
  String get login_view_forgot_password => 'Забув пароль';

  @override
  String get login_view_not_registered_yet =>
      'Ще не зареєстрований? Реєструйся!';

  @override
  String get email_text_field_placeholder => 'Введи свою пошту';

  @override
  String get password_text_field_placeholder => 'Введи свій пароль';

  @override
  String get forgot_password => 'Забув пароль';

  @override
  String get forgot_password_view_generic_error =>
      'Не вдалося обробити запит. Перевір, чи ти зареєстрований, або повернися назад і створи акаунт.';

  @override
  String get forgot_password_view_prompt =>
      'Якщо забув пароль, просто введи свою пошту — ми надішлемо тобі лист для відновлення паролю.';

  @override
  String get forgot_password_view_send_me_link =>
      'Надіслати посилання для відновлення паролю';

  @override
  String get forgot_password_view_back_to_login => 'Назад до входу';

  @override
  String get register_error_weak_password =>
      'Пароль занадто слабкий. Обери інший!';

  @override
  String get register_error_email_already_in_use =>
      'Ця пошта вже використовується. Спробуй іншу!';

  @override
  String get register_error_generic =>
      'Не вдалося зареєструватися. Спробуй пізніше!';

  @override
  String get register_error_invalid_email =>
      'Схоже, ця пошта некоректна. Введи іншу адресу!';

  @override
  String get register_view_prompt =>
      'Введи пошту та пароль, щоб побачити свої книги!';

  @override
  String get register_view_already_registered => 'Вже є акаунт? Увійди тут!';

  @override
  String get verify_email_view_prompt =>
      'Ми надіслали лист для підтвердження. Відкрий його, щоб підтвердити акаунт. Якщо листа ще немає — натисни кнопку нижче!';

  @override
  String get verify_email_send_email_verification =>
      'Надіслати лист для підтвердження';

  @override
  String notes_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count книг(а)',
      one: '1 книга',
      zero: 'Поки що немає книг',
    );
    return '$_temp0';
  }
}
