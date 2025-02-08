## 1.ORM

- ORM：对象关系映射，其主要作用是在编程中，把面向对象的概念跟数据库中的概念对应起来

  - 定义一个对象，就对应着一张表，这个对象的实例就对应着表中的一条记录

    ![ORM](https://image.jslog.net/online/a-28/2024/12/02/ORM.svg)

  - 对比

    - 传统SQL

      ```sql
      SELECT id,first_name,last_name,phone,birth_date,sex FROM persons WHERE id = 10
      ```

      ```js
      res = db.execSql(sql)
      name = res[0]['FIRST_NAME']
      ```

    - ORM

      ```js
      p = Person.get(10)
      name = p.first_name
      ```

- ORM特点

  - 方便维护：数据模型定义在同一个地方，利于重构
  - 代码量少，对接多种数据库：代码逻辑更易懂
  - 工具多、自动化能力强：数据库删除关联数据、事务操作等

## 2.TypeORM集成

- 安装：`pnpm i --save @nestjs/typeorm typeorm mysql2`

- 配置文件

  - .env

    ```structured text
    DB_TYPE=mysql
    DB_HOST=127.0.0.1
    DB_PORT=3307
    
    DB_SYNC=false
    ```

  - .env.development

    ```structured text
    DB_USERNAME=root
    DB_PASSWORD=example
    DB_DATABASE=testdb
    
    DB_SYNC=true
    ```

  - .env.production

    ```structured text
    DB_USERNAME=root
    DB_PASSWORD=long-random-password
    DB_DATABASE=proddb
    
    DB_SYNC=true
    ```

  - docker-compose.yml

    ```dockerfile
    version: '3.1'
    
    services:
      db:
        image: mysql
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: example
        ports:
          - 3307:3306
    
    
      adminer:
        image: adminer
        restart: always
        ports:
          - 8080:8080
    ```

- app.modules.ts

  ```ts
  import { Module } from '@nestjs/common';
  import { UserModule } from './user/user.module';
  import { ConfigModule, ConfigService } from '@nestjs/config';
  import * as dotenv from 'dotenv';
  import * as Joi from 'joi';
  import { TypeOrmModule, TypeOrmModuleOptions } from '@nestjs/typeorm';
  import { ConfigEnum } from './enum/config.enum';
  
  const envFilePath = `.env.${process.env.NODE_ENV || `development`}`;
  
  @Module({
    imports: [
      ConfigModule.forRoot({
        isGlobal: true,
        envFilePath,
        load: [() => dotenv.config({ path: '.env' })],
        validationSchema: Joi.object({
          NODE_ENV: Joi.string()
            .valid('development', 'production')
            .default('development'),
          DB_TYPE: Joi.string().valid('mysql','postgres'),
          DB_HOST: Joi.string().ip(),
          DB_PORT: Joi.number().default(3307),
          DB_USERNAME: Joi.string().required(),
          DB_PASSWORD: Joi.string().required(),
          DB_DATABASE: Joi.string().required(),
          DB_SYNC: Joi.boolean().default(false)
        }),
      }),
      TypeOrmModule.forRootAsync({
        imports:[ConfigModule],
        inject:[ConfigService],
        useFactory:(configService: ConfigService)=>({
            type:configService.get(ConfigEnum.DB_TYPE),
            host:configService.get(ConfigEnum.DB_HOST),
            port:configService.get(ConfigEnum.DB_PORT),
            username:configService.get(ConfigEnum.DB_USERNAME),
            password:configService.get(ConfigEnum.DB_PASSWORD),
            database:configService.get(ConfigEnum.DB_DATABASE),
            entities:[],
            // 同步本地的schema与数据库->初始化的时候去使用
            synchronize:configService.get(ConfigEnum.DB_SYNC),
            logging:['error'],
        } as TypeOrmModuleOptions)
      }),
      // TypeOrmModule.forRoot({
      //   type:'mysql',
      //   host:'localhost',
      //   port:3307,
      //   username:'root',
      //   password:'example',
      //   database:'testdb',
      //   entities:[],
      //   // 同步本地的schema与数据库->初始化的时候去使用
      //   synchronize:true,
      //   logging:['error'],
      // }),
      UserModule,
    ],
    controllers: [],
    providers: [],
  })
  export class AppModule {}
  
  ```

## 3.TypeORM仓库模式

![ER](https://image.jslog.net/online/a-28/2024/12/02/ER.svg)

- users.entity.ts

  ```ts
  import { Logs } from 'src/logs/logs.entity';
  import { Roles } from 'src/roles/roles.entity';
  import { Column, Entity, JoinTable, ManyToMany, OneToMany, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
  import { Profile } from './profile.entity';
  
  @Entity()
  export class Users {
    @PrimaryGeneratedColumn()
    id: number;
    @Column()
    username: string;
    @Column()
    password: string;
  
    // typescript -> 数据库 关联关系 Mapping
    @OneToMany(()=>Logs, (logs)=>logs.user)
    logs:Logs[]
  
    @ManyToMany(()=>Roles, (roles)=>roles.users) 
    @JoinTable({name:'user_roles'})
    roles:Roles[]
  
    @OneToOne(()=>Profile,(profile)=>profile.user)
    profile: Profile
  }
  ```

- profile.entity.ts

  ```ts
  import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
  import { Users } from './users.entity';
  
  @Entity()
  export class Profile {
    @PrimaryGeneratedColumn()
    id: number;
    @Column()
    gender: string;
    @Column()
    photo: string;
    @Column()
    address: string;
  
    @OneToOne(()=>Users)
    @JoinColumn()
    user:Users
  }
  
  ```

- roles.entity.ts

  ```ts
  import { Users } from './users.entity';
  import { Column, Entity, ManyToMany, PrimaryGeneratedColumn } from 'typeorm';
  
  @Entity()
  export class Roles {
    @PrimaryGeneratedColumn()
    id: number;
    @Column()
    name: string;
  
    @ManyToMany(()=>Users, (users)=>users.roles)
    users:Users[]
  }
  
  ```

- logs.entity.ts

  ```ts
  import { Users } from './users.entity'
  import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
  
  @Entity()
  export class Logs {
    @PrimaryGeneratedColumn()
    id:number
    @Column()
    path:string
    @Column()
    method:string
    @Column()
    data:string
    @Column()
    result:number
    
    @ManyToOne(()=>Users,(user)=>user.logs)
    @JoinColumn()
    user:Users
  }
  ```

  

## 4.TypeORM的增删改查

![DI容器工作原理](https://image.jslog.net/online/a-28/2024/12/02/DI容器工作原理.svg)

- user.module.ts：引入TypeOrmModule模块

  ```ts
  import { Module } from '@nestjs/common';
  import { UserController } from './user.controller';
  import { UserService } from './user.service';
  import { TypeOrmModule } from '@nestjs/typeorm';
  import { Users } from './users.entity';
  import { Logs } from 'src/logs/logs.entity';
  
  @Module({
    imports:[TypeOrmModule.forFeature([Users,Logs])],
    controllers: [UserController],
    providers: [UserService],
  })
  export class UserModule {}
  ```

- user.service.ts：增删改查，一对一查询（Users，Profile），一对多查询（Users，Logs）

  ```ts
  import { Injectable } from '@nestjs/common';
  import { InjectRepository } from '@nestjs/typeorm';
  import { Users } from './users.entity';
  import { Repository } from 'typeorm';
  import { Logs } from 'src/logs/logs.entity';
  
  @Injectable()
  export class UserService {
    constructor(
      @InjectRepository(Users) private readonly userRepository: Repository<Users>,
      @InjectRepository(Logs) private readonly logsRepository: Repository<Logs>,
    ) {}
    findAll() {
      return this.userRepository.find();
    }
    find(username: string) {
      return this.userRepository.findOne({ where: { username } });
    }
    findOne(id: number) {
      return this.userRepository.findOne({ where: { id } });
    }
    async create(user: Users) {
      const userTmp = await this.userRepository.create(user);
      return this.userRepository.save(userTmp);
    }
    update(id: number, user: Partial<Users>) {
      return this.userRepository.update(id, user);
    }
    remove(id: number) {
      return this.userRepository.delete(id);
    }
  
    findProfile(id: number) {
      return this.userRepository.findOne({
        where: {
          id,
        },
        relations: {
          profile: true,
        },
      });
    }
    async findUserLogs(id: number) {
      const user = await this.findOne(id)
      return this.logsRepository.find({
        where: {
          user
        },
        relations: {
          user: true,
        },
      });
    }
  }
  ```

- user.controller.ts

  ```ts
  import { Controller, Delete, Get, Post, Put } from '@nestjs/common';
  import { UserService } from './user.service';
  import { ConfigService } from '@nestjs/config';
  import { Users } from './users.entity';
  
  @Controller('user')
  export class UserController {
    constructor(
      private userService: UserService,
      private configService: ConfigService,
    ) {}
  
    @Get()
    getUsers(): any {
      return this.userService.findAll();
    }
  
    @Post()
    addUser(): any {
      const user = { username: 'js', password: '123456' } as Users;
      return this.userService.create(user);
    }
    @Put()
    updateUser(): any {
      const user = { username: 'jacobsu' } as Users;
      return this.userService.update(2, user);
    }
    @Delete()
    removeUser(): any {
      return this.userService.remove(1);
    }
  
    @Get('/profile')
    getUserProfile(): any {
      return this.userService.findProfile(2);
    }
  
    @Get('/logs')
    getUserLogs(): any {
      return this.userService.findUserLogs(2);
    }
  }
  ```

## 5.TypeORM query与createQueryBuilder

- query

  ```ts
  this.logsRepository.query(
  	`SELECT logs.result AS result, users.id AS users_id, users.username AS users_username, users.password AS users_password, COUNT("logs.reuslt") AS count FROM logs logs LEFT JOIN users users ON users.id=logs.userId WHERE users.id = ${id} GROUP BY logs.result ORDER BY count DESC, result DESC LIMIT 3 OFFSET 2`
  );
  ```

  

- createQueryBuilder

  ```ts
  this.logsRepository
    .createQueryBuilder('logs')
    .select('logs.result','result')
    .addSelect('COUNT("logs.reuslt")','count')
    .leftJoinAndSelect('logs.user', 'users')
    .where('users.id = :id', { id })
    .groupBy('logs.result')
    .orderBy('count','DESC')
    .addOrderBy('result','DESC')
    .offset(2)
    .limit(3)
    // .orderBy('result','DESC')
    .getRawMany();
  ```

  