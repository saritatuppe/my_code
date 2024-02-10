#from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db import connection
from apps.utils import *
# from models import *
# from serializers import *
from apps.utils import dictfetchall
from django.http import HttpResponse
import random
from apps.utils import sendEmail
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db import connection


class Register(APIView):
    def get(self, request, recno = None):
        success = False
        try:
            if recno: 
                get = "SELECT * FROM entity WHERE recno = %s AND active = True"
                with connection.cursor() as c:
                    c.execute(get, [recno])
                    row = dictfetchall(c)
                success = True
            else:
                get = "SELECT * FROM entity WHERE active = True"
                with connection.cursor() as c:
                    c.execute(get)
                    row = dictfetchall(c)
                success = True

            return Response({'Success' : success, 'Message' : row}, status=200)
        
        except Exception as err:
            import os
            import sys
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)
            return Response({'Success' : success, 'Error' : str(err)}, status=400)


    def post(self, request):

        success = False
        try:
            request_data = request.data

            descn = request_data['descn']
            emailid= request_data['emailid']
            mobile= request_data['mobile']
            emailid=request_data['emailid'] 
            collage_name=request_data['collage_name']
            university_name=request_data['university_name']
            bdate= request_data['bdate'] 
            seat_no=request_data['seat_no']
            usertype_recno=request_data['usertype_recno']
            # active = request_data.get('active', 1)

            
            if descn != None:
                add = "INSERT INTO entity(descn, emailid, mobile, collage_name, university_name, bdate, seat_no, usertype_recno) VALUES (%s,%s, %s,%s, %s, %s, %s,%s)"

                with connection.cursor() as c:
                    c.execute(add, [descn, emailid, mobile, collage_name, university_name, bdate, seat_no, usertype_recno ])
                
                get = "SELECT * FROM entity ORDER BY recno DESC LIMIT 1"
                with connection.cursor() as c:
                    c.execute(get)
                    row = dictfetchall(c)

                success = True

                return Response({'Success': success, 'Message': row}, status=200)
            
            else:

                return Response({'Success': success, 'Error': 'errors'}, status=400)
                    
        except Exception as err:
            import os
            import sys
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)
            return Response({'Success' : success, 'Error' : str(err)}, status=400)


    def patch(self, request):

            success=False
            try:
                request_data = request.data
                recno= request_data.get('recno',None)
                descn = request_data.get('descn',None)
                emailid= request_data.get('emailid',None)
                mobile= request_data.get('mobile',None)
                collage_name=request_data.get('collage_name',None)
                university_name=request_data.get('university_name',None)
                bdate= request_data.get('bdate',None)
                seat_no=request_data.get('seat_no',None)
                usertype_recno=request_data.get('usertype_recno',None)
                active = request_data.get('active', 1)

                update = 'UPDATE entity SET descn = %s, emailid=%s, mobile=%s, collage_name=%s, university_name=%s, bdate=%s, seat_no=%s, usertype_recno=%s, active=%s WHERE recno = %s'
                with connection.cursor() as c:
                    c.execute(update, [descn, emailid, mobile, collage_name, university_name, bdate, seat_no, usertype_recno,  active, recno])
                

                return Response({'Success': True, 'Message': 'Updated Successfully'}, status= 200)
            
            except Exception as err:
                import os
                import sys

                exc_type, exc_obj, exc_tb = sys.exc_info()
                fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                print(exc_type, fname, exc_tb.tb_lineno)
                return Response({'Success' : False, 'Error' : str(err)}, status=400)
            
    
    def delete(self, request):

            # success = False

            try:
                request_data = request.data
                recno = request_data['recno']

                delete = 'UPDATE entity SET active = False WHERE recno = %s'

                with connection.cursor() as c:
                    c.execute(delete, [recno])
                
                success = True
                return Response({'Success': success, 'Message': 'Deleted Successfully'}, status=200)
            
            except Exception as err:
                import os
                import sys
                exc_type, exc_obj, exc_tb = sys.exc_info()
                fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                print(exc_type, fname, exc_tb.tb_lineno)
                return Response({'Success' : False, 'Error' : str(err)}, status=400)

class Login(APIView):
    def post(self, request):

        success = False
        try:
            request_data = request.data

            emailid = request_data.get('emailid', None)
            mobile= request_data.get('mobile', None)
            pwd = request_data.get('pwd',None)

            if not (emailid or mobile) or not pwd:
                return Response({'Success': False, 'Error': 'Missing email/mobile or password'}, status=400)

            query_conditions = []
            if emailid:
                query_conditions.append(f"emailid = '{emailid}'")
            if mobile:
                query_conditions.append(f"mobile = '{mobile}'")
            if pwd:
                query_conditions.append(f"pwd = '{pwd}'")

            check = f"SELECT e.recno, e.descn, e.emailid, e.mobile, e.collage_name, e.university_name, e.bdate, e.seat_no, e.usertype_recno, e.pwd, e.active, u.type FROM entity as e inner join usertype as u on e.usertype_recno = u.recno WHERE {' AND '.join(query_conditions)}"
            print(check)
            with connection.cursor() as c:
                c.execute(check)
                row=dictfetchall(c)

            if len(row) > 0:
                expected_pass = row[0]['pwd']

                if pwd != expected_pass: # char by char check the value 
                    return Response({'Success': False, 'Error': 'Invalid Password'})
                else:
                    return Response({'Success': True, 'Message': "Login is Successful", 'userdata':row})
            
            return Response ({'Success': False, 'Error': 'Invalid Credentials'})


        except Exception as err:
            import os
            import sys
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)
            return Response({'Success' : success, 'Error' : str(err)}, status=400)

class Setpassword(APIView):
    def post(self, request):
        
        success = False
        try:
            request_data = request.data
            emailid = request_data['emailid']
            newpwd = request_data['newpwd']
            confirmpwd = request_data['confirmpwd']

            query =f"SELECT * FROM entity WHERE emailid= %s"
            with connection.cursor() as c:
                c.execute(query, [emailid])
                row=dictfetchall(c)


            if len(row)>0:
                if confirmpwd != newpwd:
                    return Response({'Success':False, "Message":"newpwd and confirm password does not match"})
                else:        
                    query=f"UPDATE entity SET pwd=%s WHERE emailid=%s"
                    with connection.cursor() as c:
                        c.execute(query, [ newpwd, emailid ])
                        
                    query = f"""Select * from entity Where emailid = %s """
                    with connection.cursor() as c:
                        c.execute(query, [emailid])
                        row=dictfetchall(c)
                    return Response({'success':True, "message":"update password successfully"})

        except Exception as err:
            import os
            import sys
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)
            return Response({'Success' : success, 'Error' : str(err)}, status=400)


class Forgotpassword(APIView):
    def post(self, request):
        
        success = False
        try:
            request_data = request.data
            emailid = request_data['emailid']

            query = f"""Select * from entity Where emailid = %s """
            with connection.cursor() as c:
                c.execute(query, [emailid])
                row=dictfetchall(c)

            if len(row)>0:
                expected_email = row[0]['emailid']

                if emailid != expected_email:
                    return Response({"Success": False, "Message": "UserId does not exist"})

            else:
                return Response({"Success": False, "Message": "UserId does not exist"})

            otp = random.randint(1000, 9999)
            send = sendEmail(otp,emailid)
            print(send)

            query = f"""UPDATE entity SET otp = %s WHERE emailid = %s"""
            with connection.cursor() as c:
                c.execute(query, [otp, emailid])
                
            get = f" SELECT * FROM entity where emailid = %s "
            with connection.cursor() as c:
                c.execute(get, [emailid])
                row=dictfetchall(c)
           

            return Response ({"Success": True, "Message": "Otp sent successfully"})
            
        except Exception as err:
            import os
            import sys
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)
            return Response({'Success' : success, 'Error' : str(err)}, status=400)

class Verifyotp(APIView):
    def post(self, request):
        success = True
        try:
            request_data = request.data
            emailid = request_data['emailid']
            otp = request_data['otp']

            query = f"""SELECT * FROM entity WHERE emailid=%s"""
            with connection.cursor() as c:
                c.execute(query, [emailid])
                row = dictfetchall(c)

            if len(row) > 0:
                expected_otp = row[0]['otp']
                if otp != expected_otp:
                    return Response({"Success": False, "Message": "otp does not match"})
                else:
                    return Response({"Success": True, "Message": "otp verified successfully "})
            else:
                return Response({"Success": False, "Message": "Email ID not found"})

        except Exception as err:
            import os
            import sys
            exc_type, exc_obj, exc_tb = sys.exc_info()
            fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
            print(exc_type, fname, exc_tb.tb_lineno)
            return Response({'Success': success, 'Error': str(err)}, status=400)


