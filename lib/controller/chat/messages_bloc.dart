import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tour_ease/controller/chat/chat_state.dart';
import 'package:tour_ease/model/chat/chatRepo.dart';
import 'package:tour_ease/model/chat/message.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatService chatService;


  MessagesBloc({required this.chatService}) : super(MessagesInitial()) {
    on<MessagesEvent>((event, emit) {

    });
    // on<SendMessage>((SendMessage event, emit)async {
    // });
    on<LoadMessages>((LoadMessages event, emit)async {

      emit(MessagesLoading());

      try {
        final messages = await chatService.fetchMessages(event.otherUserId);

        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessagesError(e.toString()));
      }
    });
  }
}
