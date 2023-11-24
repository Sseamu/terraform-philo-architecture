// const AWS = require("aws-sdk");
// const s3 = new AWS.S3();
// const cloudwatchlogs = new AWS.CloudWatchLogs();

// exports.handler = async (event) => {
//   const bucket = event.Records[0].s3.bucket.name;
//   const key = decodeURIComponent(
//     event.Records[0].s3.object.key.replace(/\+/g, " ")
//   );

//   const params = {
//     Bucket: bucket,
//     Key: key,
//   };

//   try {
//     const data = await s3.getObject(params).promise();
//     const logs = data.Body.toString("utf-8");

//     const cloudwatchParams = {
//       logEvents: [
//         {
//           message: logs,
//           timestamp: Date.now(),
//         },
//       ],
//       logGroupName: "Myphijloberryweblogs",
//       logStreamName: "s3imguploadlogs",
//     };

//     await cloudwatchlogs.putLogEvents(cloudwatchParams).promise();
//   } catch (error) {
//     console.log(error);
//     throw error;
//   }
// };
