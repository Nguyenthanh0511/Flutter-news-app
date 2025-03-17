part of 'main_news_bloc.dart';
//Dependency thêm ( equatable)


abstract class MainNewsEvent extends Equatable{
  @override
  List<Object> get props => [];

}
class MainNewsGetRecentEvent extends MainNewsEvent{}