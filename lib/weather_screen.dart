import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String , dynamic>> weather ;
  Future<Map<String , dynamic>> getCurrentWeather()async{//changes done in pubsec.yaml
  try{
    String cityName ='London';
  final res=await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey')
      );//Uri=uniform resource identifier
    
    final data=  jsonDecode(res.body); //data from the weather api
    if(data['cod']!='200'){
      throw 'an unexpected error occured';
    }

    return data;
    //temp=data['list'][0]['main']['temp']; 
    
  }catch(e){
    throw e.toString();
  }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Weather App',
          style:TextStyle(
          fontWeight: FontWeight.bold,
           ),
        ),
        centerTitle: true,
        actions:[
          //gesturedetector doesnt have splash efffect , but it is more advanaced then inkwell , iconbutton provides padding
          IconButton(
            onPressed: () {
              setState(() {//local state management
                weather = getCurrentWeather();
              });
            }, 
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:FutureBuilder(//future of the object 
        future:weather ,
        builder:(context, snapshot) {
          print(snapshot); //snapshot is a class that helps us to handle states of our objects - like loading , error etc.
          print(snapshot.runtimeType);
          //loading state
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator.adaptive()
              ); //for reloading
          }
          //error state
          if(snapshot.hasError){
            return  Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data;
          final currentWeatherData = data?['list']?[0];
          final currentTemp = currentWeatherData?['main']?['temp']??0.0; 
          final currentSky = currentWeatherData?['weather']?[0]?['main'];
          final currentPressure = currentWeatherData?['main']?['pressure']??0.0; 
          final currentWS = currentWeatherData?['wind']?['speed']??0.0; 
          final currentHumidity = currentWeatherData?['main']?['humidity']??0.0; 

          //print('$currentSky');

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,//everything starts from left hand side
            children:[
              //main card
              SizedBox(
                width:double.infinity,
                child: Card(
                  elevation: 10,
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:ClipRRect(//when using blur,the elevation just vanishes,hence we use cliprrect to establish the boundary of the box again
                    borderRadius:BorderRadius.circular(16) ,
                    child: BackdropFilter(
                      filter:ImageFilter.blur(sigmaX: 10,sigmaY: 10),//creates blur effect 
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(//start with column,then keep adding widgets like padding and cliprrect etc
                          children: [
                            Text('$currentTemp K',
                            style:const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                            SizedBox(height:16),//creates space between the text and the cloud icon
                            Icon(
                              currentSky == 'Rain'
                                ? Icons.water_drop
                                  : currentSky == 'Clouds'
                                    ? Icons.cloud
                                      : currentSky == 'Snow'
                                        ? Icons.ac_unit
                                          : currentSky == 'Thunderstorm'
                                            ? Icons.flash_on
                                              : Icons.wb_sunny,
                              size:64,
                              ),
                            SizedBox(height:16),//creates space between the icon and the smaller text
                            Text(currentSky,
                              style:const TextStyle(fontSize: 20),
                              ),
                            ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height:20),
              const Text('Hourly forecast',//if not using crossaxisalignment , use Align widget => alignment: Alignment.centerLeft,
              style:TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )
              ),
              const SizedBox(height:8),
              /*SingleChildScrollView(//makes the widget scrollable
                scrollDirection: Axis.horizontal,//to make it scroll in horizontal direction
                child: Row(//weather forecast cards
                  children: [
                    for(int i=0;i<5;i++)
                      HourlyForecastItem(
                      icon: data?['list']?[i + 1]?['weather']?[0]?['main'] == 'Rain'
                        ? Icons.water_drop
                          : data?['list']?[i + 1]?['weather']?[0]?['main'] == 'Clouds'
                            ? Icons.cloud
                              : data?['list']?[i + 1]?['weather']?[0]?['main'] == 'Snow'
                                ? Icons.ac_unit
                                  : Icons.wb_sunny, 
                      //(data?['list']?[i+1]?['weather']?[0]?['main'] == 'Clouds' || data?['list']?[i+1]?['weather']?[0]?['main'] == 'Rain' )? Icons.cloud : Icons.sunny,
                      label:data?['list']?[i+1]?['dt']?.toString()??'n/a',
                      value:data?['list']?[i+1]?['main']?['temp']?.toString()??'n/a',
                      ),
                  ],
                ),
              ),*/
              SizedBox(
                height: 120,
                child: ListView.builder(//listview has a tendency of occupying the entire screen
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context , index){
                    final HourlyForecast = data?['list']?[index+1];
                    final time = DateTime.parse(HourlyForecast?['dt_txt']?.toString()??'n/a');//extracts date time from api
                    return HourlyForecastItem(
                      icon:  HourlyForecast?['weather']?[0]?['main'] == 'Rain'
                          ? Icons.water_drop
                            : HourlyForecast?['weather']?[0]?['main'] == 'Clouds'
                              ? Icons.cloud
                                : HourlyForecast?['weather']?[0]?['main'] == 'Snow'
                                  ? Icons.ac_unit
                                    : Icons.wb_sunny,  
                      label: DateFormat.Hm().format(time), //only accepts the time and converts it to hour minute
                      value: HourlyForecast?['main']?['temp']?.toString()??'n/a',
                      );
                  },
                ),
              ),
              const SizedBox(height:20),
              const Text(
                'Additional Information',
                style:TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height:8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, //adjusts spacing automatically
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label:'Humidity',
                    value:currentHumidity.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label:'Wind speed',
                    value:currentWS.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.arrow_downward,
                    label:'Pressure',
                    value:currentPressure.toString(),
                  ),
                ],
              ),
            ],
          ),
          );
        },
       )
    );
  }
}


