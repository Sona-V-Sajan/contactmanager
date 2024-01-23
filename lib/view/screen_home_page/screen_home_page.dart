
import 'package:contactmanager/sql_helper/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Contact_Manager extends StatefulWidget {

  @override
  State<Contact_Manager> createState() => _Contact_ManagerState();
}

class _Contact_ManagerState extends State<Contact_Manager> {
  List<Map<String,dynamic>> contacts =[];

  @override
  Widget build(BuildContext context) {
    // contacts.sort(compareContacts);
    return SafeArea(
      child: Scaffold(
        appBar:  AppBar(
          bottom: PreferredSize(preferredSize: Size.fromHeight(50.0) , child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: TextField(
                onChanged: (query) {
                },
                decoration: const InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.search,size: 20,color: Colors.black,),
                ),
              ),
            ),
          ),),
          backgroundColor:Colors.blue,
          title: const Center(child: Text("Contact Manager",
            style:
            TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold),)),
          actions: [
            IconButton(
                onPressed: ()=>showsheet(null),
                icon: Icon(Icons.add,size: 24,color: Colors.white,)),
          ],
        ),
        body: contacts.isEmpty? Center(child: Text("No contact is found",style: TextStyle(fontWeight: FontWeight.w700,fontSize:20)))
            :ListView.builder(itemCount:contacts.length,
            itemBuilder: (context,index){
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: ()=>showsheet(contacts[index]['id']),
                  child: Slidable(
                  startActionPane: ActionPane(motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.red,
                          onPressed: (context)=>deleteContact(contacts[index]['id']),
                          icon: Icons.delete,
                        )
                      ]),

                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person,size: 24,color: Colors.white,),
                          backgroundColor: Colors.primaries[index% Colors.primaries.length
                          ],
                        ),
                        title: Text(contacts[index]['cname']),
                        subtitle: Text(contacts[index]['cnumber']),
                        trailing: Text(contacts[index]['cemail']),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
  final nameController =TextEditingController();
  final numController =TextEditingController();
  final emailController =TextEditingController();

  void showsheet(int? id) {
    if(id != null){
      final existingcontact = contacts.firstWhere((element) => element['id'] == id );
      nameController.text = existingcontact['cname'];
      numController.text = existingcontact['cnumber'];
      emailController.text = existingcontact['cemail'];

    }
    showModalBottomSheet(
        isScrollControlled:true,
        context: context, builder:(context){
      return Container(
        padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom:MediaQuery.of(context).viewInsets.bottom+120
        ),
        child: Column(
          children: [
           SizedBox(height: 20,),
            TextFormField(
              controller:nameController,
              decoration: InputDecoration(
                hintText: "Name",
                labelText: "Name",
                border:OutlineInputBorder(),
              ),),
            SizedBox(height: 20,),
            TextFormField(
              keyboardType:TextInputType.number,
                controller: numController,
                decoration: InputDecoration(
                  hintText: "Number",
                  labelText: "Number",
                  border:OutlineInputBorder(),
                )),
            SizedBox(height: 20,),
            TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  labelText: "Email",
                  border:OutlineInputBorder(),
                )),
            SizedBox(height: 20,),
            ElevatedButton(
              style:ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
                onPressed: (){

             if(id == null){
               createContact(
                 nameController.text,
                 numController.text,
                 emailController.text,
               );
             }
             if(id !=null){
               updateContact(id);
             }
             nameController.clear();
             numController.clear();
             emailController.clear();
             Navigator.pop(context);
           }
           , child: Text(id == null ? "create contact":"update contact" ,style:
                TextStyle(color: Colors.white,fontWeight:FontWeight.w700,fontSize: 20),))
          ],
        ),
      );

    } );
  }

  Future<void> createContact(String name, String number,String email) async{
    await SQLHelper.addnewContact(name,number,email);
    getContact_and_refresh_Ui();
  }
  @override
  void initState() {
    getContact_and_refresh_Ui();
    super.initState();
  }

  Future <void> getContact_and_refresh_Ui() async{
    final mycontacts = await SQLHelper.getContacts();
    setState(() {
      contacts = mycontacts;
      // isloading = false;
    });

  }

  Future <void> updateContact(int id) async{
    await SQLHelper.editContact(id,nameController.text,numController.text,emailController.text);
    getContact_and_refresh_Ui();
  }

  Future<void> deleteContact(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: Text('Do you want to delete this contact?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await SQLHelper.deleteContact(id);
                getContact_and_refresh_Ui();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Successfully deleted'),
                ));

                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }


  // int compareContacts(Map<String, dynamic> a, Map<String, dynamic> b) {
  //   return a['cname'].compareTo(b['cname']);
  // }
}
