import { IsPhoneNumber, IsString } from 'class-validator';

export class SendOtpDto {
  @IsString()
  phone: string;
}

