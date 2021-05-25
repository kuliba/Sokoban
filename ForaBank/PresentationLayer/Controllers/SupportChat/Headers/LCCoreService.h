//
//  LCLivetexEngine.h
//  LivetexCore
//
//  Created by Эмиль Абдуселимов on 15.06.16.
//  Copyright © 2016 Livetex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCCoreTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class LCCoreService;
@protocol LCCoreServiceDelegate;

@interface LCCoreService : NSObject

@property(nonatomic, weak) id<LCCoreServiceDelegate> delegate;

/*!
 *  @brief Инициализирует и возвращает объект LCCoreService с указанными параметрами
 *
 *  @param URL              Адрес сервера регистрации Livetex
 *  @param appID            Идентификатор точки контакта
 *  @param appKey           Ключ приложения
 *  @param token            Токен системы Livetex
 *  @param deviceToken      Токен APNS, полученный при регистрации от iOS
 *  @param callbackQueue    Очередь в которой будут выполняться callback блоки
 *  @param delegateQueue    Очередь в которой будут выполняться методы LCCoreServiceDelegate
 *
 *  @return Инициализированный объект LCCoreService
 *
 *  @discussion Все методы объекта LCCoreService выполняются в последовательной очереди. 
 *  По умолчанию для выполнения callback и delegate методов используется главная очередь, если иное не указано
 */
- (instancetype)initWithURL:(nonnull NSString *)URL
                      appID:(nonnull NSString *)appID
                     appKey:(nonnull NSString *)appKey
                      token:(nullable NSString *)token
                deviceToken:(nullable NSString *)deviceToken
              callbackQueue:(nullable NSOperationQueue *)callbackQueue
              delegateQueue:(nullable NSOperationQueue *)delegateQueue;


/*!
 *  @brief Запускает работу сервиса
 *
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с токеном
 *  полученным в системе Livetex, в противном случае с ошибкой
 */
- (void)startServiceWithCompletionHandler:(void (^)(NSString * _Nullable token, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Аннулирование сервиса и всех его параметров.
 */
- (void)invalidateService;

/*!
 *  @brief Сброс сервиса.
 *  @discussion Удаление токена последней удачной сессии(startServiceWithCompletionHandler).
 *  Каждый раз при работе в системе Livetex сервис использует токен последней удачной сессии.
 */
+ (void)resetService;

/*!
 *  @brief Получение текущего состояния диалога
 *
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с параметром
 *  "success" равным "true", в противном случае с ошибкой
 */
- (void)stateWithCompletionHandler:(void (^)(LCDialogState * _Nullable state, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Подтверждение получения сообщения пользователем.
 *
 *  @param messageID            Идентификатор сообщения
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с параметром
 *  "success" равным "true", в противном случае с ошибкой
 */
- (void)confirmMessageWithID:(NSString *)messageID completionHandler:(void (^)(BOOL success, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Получение истории сообщений
 *
 *  @param limit                Количество запрашиваемых сообщений в истории
 *  @param offset               Количество игнорируемых сообщений в истории
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler 
 *  с массивом сообщений, в противном случае с ошибкой
 */
- (void)messageHistory:(NSInteger)limit offset:(NSInteger)offset completionHandler:(void (^)(NSArray<LCMessage *> * _Nullable messages, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Получение списка назначений
 *
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler
 *  с массивом назначений, в противном случае с ошибкой
 */
- (void)destinationsWithCompletionHandler:(void (^)(NSArray<LCDestination *> * _Nullable destinations, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Устанавливает на кого будет назначаться обращение пользователя(оператор, точка контакта, департамент)
 *
 *  @param destination          Назначение
 *  @param attributes           Атрибуты обращения
 *  @param opts                 Опции, описывающие атрибуты обращения, передаваемые по умолчанию
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с параметром
 *  "success" равным "true", в противном случае с ошибкой
 */
- (void)setDestination:(LCDestination *)destination attributes:(LCDialogAttributes * _Nullable)attributes options:(LCDialogAttributeOptions)opts completionHandler:(void (^)(BOOL success, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Оповещает оператора о наборе текста посетителем
 *
 *  @param text                 Набираемый текст
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с параметром
 *  "success" равным "true", в противном случае с ошибкой
 */
- (void)setTyping:(NSString *)text completionHandler:(void (^)(BOOL success, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Устанавливает имя посетителя
 *
 *  @param name                 Имя посетителя
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с параметром
 *  "success" равным "true", в противном случае с ошибкой
 */
- (void)setVisitor:(NSString *)name completionHandler:(void (^)(BOOL success, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Отправляет файловое сообщение оператору. Оператору сообщение приходит в виде ссылки на объект.
 *
 *  @param data                 Данные отправляемого файла
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с параметром
 *  "response" отличным от nil, в противном случае с ошибкой
 */
- (void)sendFileMessage:(NSData *)fileData completionHandler:(void (^)(LCSendMessageResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/*!
 *  @brief Отправляет текстовое сообщение оператору
 *
 *  @param text                 Текст отправляемого сообщения
 *  @param completionHandler    Блок, который вызывается после выполнения функции
 *
 *  @discussion В случае успешного выполнения функции вызовется блок completionHandler с параметром
 *  "response" отличным от nil, в противном случае с ошибкой
 */
- (void)sendTextMessage:(NSString *)text completionHandler:(void (^)(LCSendMessageResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end


/*!
 *  LCCoreServiceDelegate протокол определяет методы, которые позволяют 
 *  реагировать на возникшие в системе Livetex события.
 */
@protocol LCCoreServiceDelegate <NSObject>

@optional

/*!
 *  @brief Оповещает об изменении состояния диалога
 *
 *  @param dialogState Состояние диалога
 */
- (void)updateDialogState:(LCDialogState *)dialogState;

/*!
 *  @brief Оповещает о наборе текста оператором
 *
 *  @param message Текст набираемый оператором
 */
- (void)receiveTypingMessage:(NSString *)message;

/*!
 *  @brief Оповещает о получении оператором сообщения
 *
 *  @param messageID Идентификатор сообщения, полученного оператором
 */
- (void)confirmMessage:(NSString *)messageID;

/*!
 *  @brief Оповещает о получении текстового сообщения от оператора
 *
 *  @param message Полученное от оператора сообщение
 */
- (void)receiveTextMessage:(LCMessage *)message;

/*!
 *  @brief Оповещает о получении файлового сообщения от оператора
 *
 *  @param message Полученное от оператора сообщение
 */
- (void)receiveFileMessage:(LCMessage *)message;

/*!
 *  @brief Оповещает об изменении адресата обращения
 *
 *  @param destinations Массив назначений
 */
- (void)selectDestination:(NSArray<LCDestination *> *)destinations;

/*!
 *  @brief Оповещает о произошедшей в системе ошибке
 *
 *  @param error Ошибка, произошедшая в системе
 */
- (void)didReceiveError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
