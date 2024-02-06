import imaplib
import email
from email.header import decode_header
from email.utils import parseaddr
from datetime import datetime, timedelta
from collections import defaultdict
import time

def connect_to_outlook(username, password):
    outlook_server = "outlook.office365.com"
    outlook_port = 993

    mail = imaplib.IMAP4_SSL(outlook_server, outlook_port)
    mail.login(username, password)
    return mail

def read_new_emails(mail):
    mail.select('inbox')
    result, data = mail.search(None, 'UNSEEN')
    email_ids = data[0].split()

    new_emails = []
    for email_id in email_ids:
        result, message_data = mail.fetch(email_id, '(RFC822)')
        raw_email = message_data[0][1]
        msg = email.message_from_bytes(raw_email)
        new_emails.append(msg)

    return new_emails

def process_new_emails(new_emails):
    for email_msg in new_emails:
        subject, encoding = decode_header(email_msg['Subject'])[0]
        subject = subject.decode(encoding) if encoding else subject
        if isinstance(subject, bytes):
                    subject = subject.decode(encoding or "utf-8")

        # Get the email body
        if email_msg.is_multipart():
            for part in email_msg.walk():
                if part.get_content_type() == "text/plain":
                    body = part.get_payload(decode=True)
                    print("Subject:", subject)
                    print("Body:", body.decode("utf-8"))
                    print("------")

        # body, encoding= decode_header(email_msg['Body'])[0]
        # body = body.decode(encoding) if encoding else body
        sender_name, sender_email = parseaddr(email_msg.get('From'))
        print(f"New Email - Sender: {sender_name} ({sender_email})")

def monitor_outlook_mailbox(username, password):
    outlook_mail = connect_to_outlook(username, password)
    
    try:
        while True:
            new_emails = read_new_emails(outlook_mail)
            if new_emails:
                process_new_emails(new_emails)
            time.sleep(10)  # Adjust the sleep interval as needed
    except KeyboardInterrupt:
        pass
    finally:
        outlook_mail.logout()

if __name__ == "__main__":
    # Replace with your Outlook credentials
    outlook_username = 'your_emailid@outlook.com'
    outlook_password = 'your_password'

    try:
        monitor_outlook_mailbox(outlook_username, outlook_password)
    except Exception as e:
        print(f"An error occurred: {e}")
