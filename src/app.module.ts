import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { CasesModule } from './cases/cases.module';
import { DonationsModule } from './donations/donations.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [PrismaModule, AuthModule, CasesModule, DonationsModule, UsersModule],
  controllers: [],
  providers: [],
})
export class AppModule {}

