//
//  LCCoreTypes.h
//  LivetexCore
//
//  Created by Эмиль Абдуселимов on 15.06.16.
//  Copyright © 2016 Livetex. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/*!
 * Количество миллисекунд от начала времен в Unix.
 */
typedef NSString * LCTimestamp;

typedef NSDictionary<NSString *, NSString *> * LCOptions;

typedef NSMutableDictionary<NSString *, NSString *> * LCMutableOptions;

/*!
 * Опции, описывающие атрибуты обращения, передаваемые по умолчанию
 *  LCDialogAttributeDeviceModel        - Модель устройства
 *  LCDialogAttributeDeviceSystem       - ОС устройства
 *  LCDialogAttributeApplicationVersion - Версия приложения
 *  LCDialogAttributeConnectionType     - Тип соединения
 *  LCDialogAttributeCarrierName        - Оператор связи
 */
typedef NS_OPTIONS(NSInteger, LCDialogAttributeOptions) {
    LCDialogAttributeDeviceModel = 1 << 0,
    LCDialogAttributeDeviceSystem = 1 << 1,
    LCDialogAttributeApplicationVersion = 1 << 2,
    LCDialogAttributeConnectionType = 1 << 3,
    LCDialogAttributeCarrierName = 1 << 4
};

/*!
 * Текстовое сообщение
 */
@interface LCTextMessage : NSObject <NSCoding, NSCopying>

/*!
 * @brief Текст сообщения.
 */
@property (strong, nonatomic) NSString * text;

/*!
 * @brief Источник сообщения.
 */
@property (strong, nonatomic, nullable) NSString * sender;

/*!
 * @brief Дата создания сообщения в миллисекундах.
 */
@property (strong, nonatomic) LCTimestamp created;

@property (assign, nonatomic) BOOL textIsSet;
@property (assign, nonatomic) BOOL senderIsSet;
@property (assign, nonatomic) BOOL createdIsSet;

- (instancetype)initWithText:(NSString *)text created:(LCTimestamp)created sender:(nullable NSString *)sender;

@end


/*!
 * Файловое сообщение
 */
@interface LCFileMessage : NSObject <NSCoding, NSCopying>

/*!
 * @brief URL переданного файла.
 */
@property (strong, nonatomic) NSString * url;

/*!
 * @brief Источник сообщения.
 */
@property (strong, nonatomic, nullable) NSString * sender;

/*!
 * @brief Дата создания сообщения в миллисекундах.
 */
@property (strong, nonatomic) LCTimestamp created;

@property (assign, nonatomic) BOOL urlIsSet;
@property (assign, nonatomic) BOOL senderIsSet;
@property (assign, nonatomic) BOOL createdIsSet;

- (instancetype)initWithUrl:(NSString *)url created:(LCTimestamp)created sender:(nullable NSString *)sender;

@end


/*!
 * Атрибуты обобщенного типа LCMessage
 */
@interface LCMessageAttributes : NSObject <NSCoding, NSCopying>

/*!
 * @brief Текстовое сообщение.
 */
@property (strong, nonatomic) LCTextMessage * text;

/*!
 * @brief Файловое сообщение.
 */
@property (strong, nonatomic) LCFileMessage * file;

@property (assign, nonatomic) BOOL textIsSet;
@property (assign, nonatomic) BOOL fileIsSet;

- (instancetype)initWithText:(LCTextMessage * _Nullable)text file:(LCFileMessage * _Nullable)file;

@end


/*!
 * Обобщенный тип сообщения, который представляет собой контейнер
 * содержащий в атрибутах либо текстовое сообщение, либо файловое сообщение
 */
@interface LCMessage : NSObject <NSCoding, NSCopying>

/*!
 * @brief Идентификатор сообщения.
 */
@property (strong, nonatomic) NSString * messageId;

/*!
 * @brief Атрибуты.
 */
@property (strong, nonatomic) LCMessageAttributes * attributes;

/*!
 * @brief Флаг доставленности.
 */
@property (assign, nonatomic) BOOL confirm;

@property (assign, nonatomic) BOOL confirmIsSet;
@property (assign, nonatomic) BOOL messageIdIsSet;
@property (assign, nonatomic) BOOL attributesIsSet;

- (instancetype)initWithMessageId:(NSString *)messageId attributes:(LCMessageAttributes *)attributes confirm:(BOOL)confirm;

@end


/*!
 * Оператор
 */
@interface LCEmployee : NSObject <NSCoding, NSCopying>

/*!
 * @brief Идентификатор оператора.
 */
@property (strong, nonatomic) NSString * employeeId;

/*!
 * @brief Актуальный статус оператора.
 */
@property (strong, nonatomic) NSString * status;

/*!
 * @brief Имя оператора.
 */
@property (strong, nonatomic) NSString * firstname;

/*!
 * @brief Фамилия оператора.
 */
@property (strong, nonatomic) NSString * lastname;

/*!
 * @brief URL аватара оператора.
 */
@property (strong, nonatomic) NSString * avatar;

/*!
 * @brief Телефон оператора.
 */
@property (strong, nonatomic, nullable) NSString * phone;

/*!
 * @brief Email оператора.
 */
@property (strong, nonatomic, nullable) NSString * email;

/*!
 * @brief Атрибуты оператора.
 */
@property (strong, nonatomic, nullable) LCMutableOptions options;

@property (assign, nonatomic) BOOL emailIsSet;
@property (assign, nonatomic) BOOL phoneIsSet;
@property (assign, nonatomic) BOOL avatarIsSet;
@property (assign, nonatomic) BOOL statusIsSet;
@property (assign, nonatomic) BOOL optionsIsSet;
@property (assign, nonatomic) BOOL lastnameIsSet;
@property (assign, nonatomic) BOOL firstnameIsSet;
@property (assign, nonatomic) BOOL employeeIdIsSet;

- (instancetype)initWithEmployeeId:(NSString *)employeeId
                            status:(NSString *)status
                         firstname:(NSString *)firstname
                          lastname:(NSString *)lastname
                            avatar:(NSString *)avatar
                             phone:(nullable NSString *)phone
                             email:(nullable NSString *)email
                           options:(nullable LCOptions)options;

@end


/*!
 * Точка контакта
 */
@interface LCTouchPoint : NSObject <NSCoding, NSCopying>

/*!
 * @brief Идентификатор точки контакта.
 */
@property (strong, nonatomic) NSString * touchPointId;
@property (assign, nonatomic) BOOL touchPointIdIsSet;

- (instancetype)initWithTouchPointId:(NSString *)touchPointId;

@end

/*!
 * Департамент
 */
@interface LCDepartment : NSObject <NSCoding, NSCopying>

/*!
 * @brief Идентификатор департамента.
 */
@property (strong, nonatomic) NSString * departmentId;

/*!
 * @brief Название департамента.
 */
@property (strong, nonatomic) NSString * name;

/*!
 * @brief Атрибуты департамента.
 */
@property (strong, nonatomic, nullable) LCMutableOptions options;

@property (assign, nonatomic) BOOL nameIsSet;
@property (assign, nonatomic) BOOL optionsIsSet;
@property (assign, nonatomic) BOOL departmentIdIsSet;

- (instancetype)initWithDepartmentId:(NSString *)departmentId name:(NSString *)name options:(nullable LCOptions)options;

@end


/*!
 * Адресат обращения
 */
@interface LCDestination : NSObject <NSCoding, NSCopying>

/*!
 * @brief Оператор.
 */
@property (strong, nonatomic) LCEmployee * employee;

/*!
 * @brief Точка контакта.
 */
@property (strong, nonatomic) LCTouchPoint * touchPoint;

/*!
 * @brief Департамент.
 */
@property (strong, nonatomic) LCDepartment * department;

@property (assign, nonatomic) BOOL employeeIsSet;
@property (assign, nonatomic) BOOL touchPointIsSet;
@property (assign, nonatomic) BOOL departmentIsSet;

- (instancetype)initWithEmployee:(LCEmployee *)employee touchPoint:(LCTouchPoint *)touchPoint department:(LCDepartment *)department;

@end

/*!
 * Сообщение оповещения о наборе текста.
 */
@interface LCTyping : NSObject <NSCoding, NSCopying>

/*!
 * @brief Набираемый текст.
 */
@property (strong, nonatomic, nullable) NSString * text;
@property (assign, nonatomic) BOOL textIsSet;

- (instancetype)initWithText:(nullable NSString *)text;

@end


/*!
 * Обращение клиента
 */
@interface LCConversation : NSObject <NSCoding, NSCopying>

/*!
 * @brief Идентификатор оператора.
 */
@property (strong, nonatomic, nullable) NSString * employeeId;

/*!
 * @brief Идентификатор департамента.
 */
@property (strong, nonatomic, nullable) NSString * departmentId;

@property (assign, nonatomic) BOOL employeeIdIsSet;
@property (assign, nonatomic) BOOL departmentIdIsSet;

- (instancetype)initWithEmployeeId:(nullable NSString *)employeeId departmentId:(nullable NSString *)departmentId;

@end


/*!
 * Статус диалога
 */
@interface LCDialogState : NSObject <NSCoding, NSCopying>

/*!
 * @brief Обращение клиента. Если обращение отсутствует, то интерфейс в состоянии NoConversation,
 *        если обращение присутствует, то возможно одно из состояний: ConversationQueued или ConversationActive.
 */
@property (strong, nonatomic, nullable) LCConversation * conversation;

/*!
 * @brief Оператор назначенный диалогу. Если оператора есть, то состояние ConversationActive,
 *        если оператора нет, то возможно одно из состояний: NoConversation или ConversationQueued.
 */
@property (strong, nonatomic, nullable) LCEmployee * employee;

@property (assign, nonatomic) BOOL employeeIsSet;
@property (assign, nonatomic) BOOL conversationIsSet;

- (instancetype)initWithConversation:(nullable LCConversation *)conversation employee:(nullable LCEmployee *)employee;

@end

/*!
 * Результат отправки сообщения
 */
@interface LCSendMessageResponse : NSObject <NSCoding, NSCopying>

/*!
 * @brief Идентификатор присвоенный отправленному сообщению.
 *        Используется для подтверждения получения ответа клиентом.
 */
@property (strong, nonatomic) NSString * messageId;

/*!
 * @brief Атрибуты отправленного сообщения
 */
@property (strong, nonatomic) LCMessageAttributes * attributes;

/*!
 * @brief Адресат сообщения которому оно будет доставлено
 */
@property (strong, nonatomic, nullable) LCDestination * destination;

@property (assign, nonatomic) BOOL messageIdIsSet;
@property (assign, nonatomic) BOOL attributesIsSet;
@property (assign, nonatomic) BOOL destinationIsSet;

- (instancetype)initWithMessageId:(NSString *)messageId attributes:(LCMessageAttributes *)attributes destination:(nullable LCDestination *)destination;

@end


/*!
 *  @discussion Атрибуты обращения.
 */
@interface LCDialogAttributes : NSObject <NSCoding, NSCopying>

/*!
 * @brief Атрибуты, которые отображаются оператору при создании обращения.
 */
@property (strong, nonatomic) LCMutableOptions visible;

/*!
 * @brief Атрибуты, которые не отображаются оператору при создании диалога, но сохраняются в системе Livetex
 */
@property (strong, nonatomic) LCMutableOptions hidden;

@property (assign, nonatomic) BOOL hiddenIsSet;
@property (assign, nonatomic) BOOL visibleIsSet;

- (instancetype)initWithVisible:(nullable LCOptions)visible hidden:(nullable LCOptions)hidden;

@end

FOUNDATION_EXPORT NSString *LCQueueTypesErrorDomain;

NS_ASSUME_NONNULL_END

