// class ApiResponse<T> extends Model {
//   ApiResponse({
//     this.success = false,
//     this.message,
//     this.data,
//   });

//   bool? success;
//   String? message;
//   T? data;

//   factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
//         success: json["success"],
//         message: json["message"] ?? '',
//         data: json["data"],
//       );

//   @override
//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "message": message,
//         "data": data,
//       };
// }

// abstract class Model {
//   Map<String, dynamic> toJson();

//   @override
//   String toString() => toJson().toString();
// }
