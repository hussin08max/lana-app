import { IsNotEmpty, IsPositive, IsString } from 'class-validator';

export class CreateDonationDto {
  @IsString()
  @IsNotEmpty()
  caseId: string;

  @IsPositive()
  amount: number;
}

