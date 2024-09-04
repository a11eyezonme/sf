# бот для оповещений сотрудников отдела продаж о заявках
# от АО Тандер "Магнит" о новых заявках со спамом в телеге
# v0.0.0.2


# ------------------------ ИМПОРТ ------------------------


# почта
import imaplib
import email
import email.header

# системные
import asyncio
import os

import aiogram.enums
from dotenv import load_dotenv,find_dotenv
load_dotenv(find_dotenv())
from datetime import datetime, timedelta
# системные -> логирование
import logging

# телеграм
from aiogram import Bot, Dispatcher


# Логирование
logging.basicConfig(level=logging.INFO, filename="py_log.log", filemode="a",
                    format="%(asctime)s - %(levelname)s - %(funcName)s: "
                           "%(lineno)d - %(message)s - %(module)s")
logging.debug("A DEBUG Message")
logging.info("An INFO")
logging.warning("A WARNING")
logging.error("An ERROR")
logging.critical("A message of CRITICAL severity")


# ---------------------- НАСТРОЙКИ -----------------------


# настройки бота
bot = Bot(token=os.getenv('TOKEN'))
dp = Dispatcher()
MY_CHANNEL_ID = os.getenv('MY_CHANNEL_ID') # добавить ID чата в .env или канала узнав его через
                             # https://telegramid.lavrynenko.com/index.php или @get_id_bot
                             # 

# настройки почты
imap_server = "imap.mail.ru"
imap = imaplib.IMAP4_SSL(imap_server)
imap.login(os.getenv('YOUR_EMAIL'), os.getenv('EMAIL_PASS'))
filter_email = **                                           # # Фильтр адресатов


# ------------------------- КОД --------------------------


# вызов каждые Х секунд
async def notify_new_mail():
    while True:
        await asyncio.sleep(10)
        try:
            imap.select("INBOX", readonly=True)
            typ, data = imap.search(None, 'UNSEEN')
            for num in data[0].split():
                res, msg = imap.fetch(num, '(RFC822)')
                msg = email.message_from_bytes(msg[0][1])
                theme = msg["Return-path"]
                text = msg["Subject"]
                text = text[text.find("="):]
                email_date = msg['Date']
                t = datetime.now()
                if text:
                    text, encoding = email.header.decode_header(text)[0]
                    if isinstance(text, bytes):
                        text = text.decode('utf-8', errors='ignore')
                    else:
                        print(f"В письме {theme} {text} тема письма на английском")
                        pass
                else:
                    text = 'БЕЗ ТЕМЫ'


                if theme in filter_email:
                    print(text)
                    if len(email_date) <= 29:
                        email_date = datetime.strptime(email_date[5:-4], "%d %b %Y %H:%M:%S") + timedelta(hours=3)
                    else:
                        email_date = datetime.strptime(email_date[5:-6], "%d %b %Y %H:%M:%S")


                    await bot.send_message(MY_CHANNEL_ID,
                                           "_Письмо от:_ \n"
                                           f"*{str(theme)}*\n"
                                           f"*______________________________________*\n"
                                           f"_Тема письма:_ \n"
                                           f"*{text}*\n"
                                           f"*______________________________________*\n"
                                           f"_Письмо пришло:_ {email_date}\n"
                                           f"*______________________________________*\n"
                                           f"_Письмо не читали:_ {t.replace(microsecond=0) - email_date}",parse_mode="Markdown")
        except (TypeError):
            print("ошибка типа", TypeError.args)
            continue



# вызов функции повторения
asyncio.run(notify_new_mail())



# ------------------------ ВЫЗОВ -------------------------

i
# инициация бота
async def main() -> None:
    await dp.start_polling(bot)


# инициация функций
if __name__ == "__main__":
    asyncio.run(main())
