import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:handicraft/customer_screen/customerhome.dart';
import 'package:handicraft/customer_screen/myorderspage.dart';

enum NavigationEvents{
  HomePageClickedEvent,
  MyAccountsClickedEvent,
  MyOrdersClickedEvent,
}
abstract class NavigationStates{}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates>{
  NavigationBloc(NavigationStates initialState) : super(initialState);

  @override
  NavigationStates get initialState => CustomerHome();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async*{
    switch(event){
      case NavigationEvents.HomePageClickedEvent:
        yield CustomerHome();
        break;
      case NavigationEvents.MyOrdersClickedEvent:
        yield OrdersPage();
        break;
    }
  }
}