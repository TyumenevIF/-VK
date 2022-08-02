# Клиент для социальной сети ВКонтакте “VK”

**Стек:** Swift, архитектура MVC, верстка контроллеров в Storyboard, UIKit, Webkit, RealmSwift, Kingfisher,
FirebaseDatabase, PromiseKit, Alamofire, VK API, GCD, NSOperation, animation.

Приложение содержит экраны авторизации на WebKit, UITabbarViewController с 3-мя вкладками:
- вкладка для отображения друзей пользователя «ВКонтакте» и его фотографий (UINavigationController — UIViewController — UICollectionViewController - UIViewController);
- вкладка для отображения групп пользователя и отображения глобального поиска групп, которые могут быть интересны пользователю (UINavigationController - UITableViewController — UITableViewController);
- вкладка с лентой новостей (UINavigationController - UITableViewController).

Созданы кастомные UI-компоненты:
- view для аватарки пользователя (круглой формы, с тенью по периметру и возможностью изменения ширины, цвета, прозрачности тени в Interface Builder (@IBDesignable, @IBInspectable);
- контрол «Мне нравится» (кнопка с иконкой сердца);
- контрол, позволяющий выбрать букву алфавита (буква – первый человек, у которого фамилия начинается на эту букву).

Выполнена анимация нажатия на аватарку пользователя/группы в соответствующих таблицах (affine transformation), анимация изменения количества отметок «Мне нравится» (transition animation), анимация появления и исчезновения ячеек с фотографиями друзей, анимация перелистывания фотографий друзей, анимация переходов между экранами в UINavigationController.

Получение данных осуществляется через VK API. Хранение данных (информация о друзьях, фото и группах) осуществляется через Realm. Экраны получают данные не от запросов к серверу, а из Realm, данные в которой регулярно обновляются. На все экраны с таблицами и коллекцией автоматическое обновление информации при изменении данных в Realm выполнено через notifications.

Работа с многопоточностью осуществляется в основном с помощью GCD (для сервиса поиска друзей VKFriendService используется NSOperation).

Для backend интегрировано в приложение Firebase (записываются в базу пользователи, которые авторизовались в приложении (id); записываются каждому пользователю группы, которые он добавлял в приложении).

Для обработки сетевых запросов на получение групп пользователя в классе VKGroupsService использован PromiseKit.

Реализовано кэширование изображений в приложении.
