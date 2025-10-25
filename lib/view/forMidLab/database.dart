class DataBaseForMidLab {




  static List<Map<String, dynamic>> users = [ {
    "name": "mohammed",
    "role": "admin",
    "password": "123456"
  }];

   static List<Map<String, dynamic>> avalibleDoctors = [{

       "name": "ali",
       "specialities": "x, y ,z",
       "time": ["sunday 1-3", "monday 3-5"]

   },
     {

       "name": "Salah",
       "specialities": "A, B ,C",
       "time": ["Friday 11-3", "Wen 3-5"]

     }];
   static List<Map<String, dynamic>> appointments = [
     {
       "name": "mohammed",
       "doctor": "Omar",
       "time": "1:30"
     }
   ];




}

