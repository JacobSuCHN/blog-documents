## 1.日志简介

- 日志的作用：记录错误并定位问题

- 日志需要怎么定位？

  - 什么事件发生的？
  - 发生了什么事情？
  - 错误是什么？

- 日志等级

  - Log：通用日志，按需进行记录（打印）
  - Warning：警告日志，比如尝试多次进行数据库操作
  - Error：严重日志：比如数据库日常
  - Debug：调试日志，比如加载数据日志
  - Verbose：详细日志，所有的操作与详细信息（非必要不打印）

- 日志按功能分类

  - 错误日志：方便定位问题
  - 调试日志：方便开发
  - 请求日志：记录敏感行为

- 日志记录位置

  - 控制台日志：方便监看（调试用）
  - 文件日志：方便回溯与追踪（24小时滚动）
  - 数据库日志：敏感操作、敏感数据记录

- NestJS中记录日志（推荐）

  |         | Log     | Error   | Warning      | Debug        | Verbose | API        |
  | ------- | ------- | ------- | ------------ | ------------ | ------- | ---------- |
  | Dev     | √       | √       | √            | √            | √       | ×          |
  | Staging | √       | √       | √            | ×            | ×       | ×          |
  | Prod    | √       | √       | ×            | ×            | ×       | √          |
  | 位置    | console | 文件/DB | console/文件 | console/文件 | console | console/DB |

## 2.NestJS内置模块Logger

- user.controller.ts

  ```ts
  import { Logger } from '@nestjs/common';
  ...
  
  @Controller('user')
  export class UserController {
    constructor(
      ...
      private logger:Logger
    ) {
      this.logger.log('UserController init')
    }
  
    @Get()
    getUsers(): any {
      this.logger.log('请求getUsers成功')
      ...
    }
    ...
  }
  ```

## 3.Pino

- 安装：`pnpm i nestjs-pino`

  - 美化日志：`pnpm i pino-pretty`
  - 滚动日志：`pnpm i pino-roll`

- app.module.ts

  ```ts
  ...
  import { LoggerModule } from 'nestjs-pino';
  import { join } from 'path';
  
  ...
  
  @Module({
    imports: [
      ...
      LoggerModule.forRoot({
        pinoHttp: {
          transport: {
            targets: [
              process.env.NODE_ENV === 'development'
                ? {
                    level: 'info',
                    target: 'pino-pretty',
                    options: {
                      colorize: true,
                    },
                  }
                : {
                    level: 'info',
                    target: 'pino-roll',
                    options: {
                      file: join('log', 'log.txt'),
                      frequency: 'daily',
                      size: '10m',
                      mkdir: true,
                    },
                  },
            ],
          },
        },
      }),
    ],
    ...
  })
  export class AppModule {}
  ```

- user.controller.ts

  ```ts
  import { Logger } from 'nestjs-pino';
  ...
  
  @Controller('user')
  export class UserController {
    constructor(
      ...
      private logger:Logger
    ) {
      this.logger.log('UserController init')
    }
  
    @Get()
    getUsers(): any {
      return this.userService.findAll();
    }
    ...
  }
  ```

## 4.Winston

- 安装：`pnpm i --save nest-winston winston`

  - 滚动日志：`pnpm i winston-daily-rotate-file`

- main.ts

  ```ts
  ...
  import { createLogger } from 'winston';
  import * as winston from 'winston';
  import { utilities, WinstonModule } from 'nest-winston';
  import 'winston-daily-rotate-file'
  
  async function bootstrap() {
    const instance = createLogger({
      transports: [
        new winston.transports.Console({
          level: 'info',
          format: winston.format.combine(
            winston.format.timestamp(),
            utilities.format.nestLike(),
          ),
        }),
        new winston.transports.DailyRotateFile({
          level: 'warn',
          dirname: 'logs',
          filename: 'application-%DATE%.log',
          datePattern: 'YYYY-MM-DD-HH',
          zippedArchive: true,
          maxSize: '20m',
          maxFiles: '14d',
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.simple(),
          ),
        }),
        new winston.transports.DailyRotateFile({
          level: 'info',
          dirname: 'logs',
          filename: 'info-%DATE%.log',
          datePattern: 'YYYY-MM-DD-HH',
          zippedArchive: true,
          maxSize: '20m',
          maxFiles: '14d',
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.simple(),
          ),
        }),
      ],
    });
    const app = await NestFactory.create(AppModule, {
      logger: WinstonModule.createLogger({ instance }),
    });
    ...
  }
  bootstrap();
  ```

- app.module.ts

  ```ts
  ...
  import { Logger } from '@nestjs/common';
  
  @Global()
  @Module({
    imports: [
    	...
    ]
    providers: [Logger],
    exports: [Logger],
  })
  export class AppModule {}
  ```

- user.controller.ts

  ```ts
  ...
  import { Logger } from '@nestjs/common';
  
  @Controller('user')
  export class UserController {
    constructor(
      ...
      private readonly logger: Logger,
    ) {
      this.logger.log('UserController init')
    }
  
    @Get()
    getUsers(): any {
      this.logger.log(`请求getUsers成功`);
      this.logger.warn(`请求getUsers成功`);
      this.logger.error(`请求getUsers成功`);
      ...
    }
    ...
  }
  ```

