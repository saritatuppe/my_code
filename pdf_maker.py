#Creating a form and generating a PDF involves designing a user-friendly interface for data input and 
#then converting that data into a PDF document.

import os
import tkinter as tk
from tkinter import filedialog, messagebox
from fpdf import FPDF

# Set the correct path for Tcl library
os.environ['TCL_LIBRARY'] = r"C:\Users\Tuppe\AppData\Local\Programs\Python\Python313\tcl\tcl8.6"

def generate_pdf():
    name = name_entry.get()
    email = email_entry.get()
    phone = phone_entry.get()
    education = education_text.get("1.0", tk.END).strip()
    skills = skills_text.get("1.0", tk.END).strip()
    experience = experience_text.get("1.0", tk.END).strip()
    projects = projects_text.get("1.0", tk.END).strip()

    if not name or not email or not phone or not education or not skills or not experience or not projects:
        messagebox.showerror("Error", "All fields must be filled out!")
        return

    # Ask user to select save location
    file_path = filedialog.asksaveasfilename(
        defaultextension=".pdf",
        filetypes=[["PDF files", "*.pdf"]],
        title="Save PDF as"
    )

    if not file_path:
        return  # User cancelled the save dialog

    # Create PDF
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=14)

    pdf.set_fill_color(0, 0, 0)
    pdf.set_text_color(255, 255, 255)
    pdf.cell(200, 15, txt="Resume Details", ln=True, align="C", fill=True)
    pdf.ln(10)

    pdf.set_text_color(0, 0, 0)
    pdf.cell(200, 10, txt=f"Name: {name}", ln=True)
    pdf.cell(200, 10, txt=f"Email: {email}", ln=True)
    pdf.cell(200, 10, txt=f"Phone: {phone}", ln=True)
    pdf.ln(5)

    sections = [("Education", education), ("Skills", skills),
                ("Experience", experience), ("Projects", projects)]

    for title, content in sections:
        pdf.set_fill_color(0, 0, 0)
        pdf.set_text_color(255, 255, 255)
        pdf.cell(200, 10, txt=title, ln=True, fill=True)
        pdf.ln(5)
        pdf.set_text_color(0, 0, 0)
        pdf.multi_cell(0, 10, content)
        pdf.ln(5)

    pdf.output(file_path)
    messagebox.showinfo("Success", f"PDF saved successfully at:\n{file_path}")

# Create GUI
root = tk.Tk()
root.title("Resume Form")
root.geometry("500x800")
root.configure(bg="black")

def create_label(text):
    return tk.Label(root, text=text, font=("Arial", 14, "bold"), fg="white", bg="black")

def create_entry():
    return tk.Entry(root, width=50, font=("Arial", 12), bg="gray", fg="white")

def create_text():
    return tk.Text(root, height=3, width=50, font=("Arial", 12), bg="gray", fg="white")

create_label("Name:").pack(pady=5)
name_entry = create_entry()
name_entry.pack()

create_label("Email:").pack(pady=5)
email_entry = create_entry()
email_entry.pack()

create_label("Phone:").pack(pady=5)
phone_entry = create_entry()
phone_entry.pack()

create_label("Education:").pack(pady=5)
education_text = create_text()
education_text.pack()

create_label("Skills:").pack(pady=5)
skills_text = create_text()
skills_text.pack()

create_label("Experience:").pack(pady=5)
experience_text = create_text()
experience_text.pack()

create_label("Projects:").pack(pady=5)
projects_text = create_text()
projects_text.pack()

submit_btn = tk.Button(root, text="Submit", command=generate_pdf, font=("Arial", 14, "bold"), bg="white", fg="black", width=20)
submit_btn.pack(pady=20)

root.mainloop()
