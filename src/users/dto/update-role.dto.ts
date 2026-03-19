import { IsEnum, IsNotEmpty } from 'class-validator';
import { UserRole } from '@prisma/client';

export class UpdateRoleDto {
  @IsNotEmpty()
  @IsEnum(UserRole)
  role: UserRole;
}

